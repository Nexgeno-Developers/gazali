<?php
_auth();
$ui->assign('_application_menu', 'manage');
$ui->assign('_title', 'Gift Box'.'- '. $config['CompanyName']);
$ui->assign('_st', 'Gift Box');
$action = $routes['1'];
$user = User::_info();
$ui->assign('user', $user);
switch ($action) {

    case 'view':
        $id  = $routes['2'];
        $item = ORM::for_table('sys_designs')->find_one($id);
        $invoiceItems = ORM::for_table('sys_invoiceitems')->where('design_id', $id)->find_many();
        $ui->assign('_title', 'History');
        $ui->assign('_st', 'History');      
        $ui->assign('p_name', $item['name']);  
        $ui->assign('invoiceItems', $invoiceItems); 
        $ui->assign('id', $id);
        $ui->display('manage/view-design.tpl');
    break;

    case 'add-design':
        
        if(!has_access($user->roleid, 'products_n_services')) {
            r2(U."dashboard",'e',$_L['You do not have permission']);
        }

        // Dynamic categories and their items
        $categories = ORM::for_table('sys_items_category')->find_array();
        $category_items = [];
        // $default_filter_branch = (string) $user->branch_id;
        foreach ($categories as $cat) {
            $items_q = ORM::for_table('sys_items')
                ->where('type', 'Product')
                ->where('product_category', $cat['value']);

            // if ($default_filter_branch !== '') {
            //     $items_q->where('branch_id', $default_filter_branch);
            // }

            $category_items[$cat['value']] = $items_q->find_array();
        }

        $ui->assign('categories', $categories);
        $ui->assign('category_items', $category_items);
        $cloths = ORM::for_table('sys_cloths')->find_many();
        $ui->assign('cloths', $cloths);

        // Branches (admins see all; staff only their branch)
        if ($user->roleid == 0) {
            $branches = ORM::for_table('sys_accounts')->order_by_asc('account')->find_array();
        } else {
            $branches = ORM::for_table('sys_accounts')->where('id', $user->branch_id)->find_array();
        }
        $ui->assign('branches', $branches);
        $ui->assign('default_branch_id', $user->branch_id);
        
        $ui->assign('type','Product');
        
        // Fetch category employees
        $categoryEmployees = ORM::for_table('category_employee')->select('id')->select('name')->find_array();
        $ui->assign('category_employees', $categoryEmployees);
        
        $css_arr = array('s2/css/select2.min');
        $js_arr = array('s2/js/select2.min','numeric');
        $ui->assign('xjq', '$(\'.amount\').autoNumeric(\'init\');');        
        Event::trigger('add_invoice_rendering_form');
        
        $ui->assign('xheader', Asset::css($css_arr));
        $ui->assign('xfooter', Asset::js($js_arr));
        
        $max = ORM::for_table('sys_items')->max('id');
        $nxt = $max+1;
        $ui->assign('nxt',$nxt);
        $ui->display('manage/add-design.tpl');
    break;        

    case 'branch-category-items':
        if(!has_access($user->roleid, 'products_n_services')) {
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode(['success' => false, 'message' => $_L['You do not have permission']]);
            break;
        }

        header('Content-Type: application/json; charset=utf-8');

        $requested_branch_id = trim((string) _get('branch_id'));
        if ($user->roleid == 0) {
            $effective_branch_id = $requested_branch_id;
        } else {
            $effective_branch_id = (string) $user->branch_id;
        }

        if ($effective_branch_id === '' || $effective_branch_id === 'all') {
            echo json_encode(['success' => true, 'branch_id' => $effective_branch_id, 'categories' => []]);
            break;
        }

        $categories = ORM::for_table('sys_items_category')
            ->select_many('name', 'value')
            ->find_array();

        $items = ORM::for_table('sys_items')
            ->select_many('id', 'name', 'product_category')
            ->where('type', 'Product')
            ->where('branch_id', $effective_branch_id)
            ->order_by_asc('name')
            ->find_array();

        $normalize_category = function ($raw) {
            $val = strtolower(trim((string) $raw));
            $val = preg_replace('/\s+/', '_', $val);
            return $val;
        };

        $items_by_category = [];
        foreach ($items as $item) {
            $key = $normalize_category($item['product_category']);
            if (!isset($items_by_category[$key])) {
                $items_by_category[$key] = [];
            }
            $items_by_category[$key][] = [
                'id' => (int) $item['id'],
                'name' => $item['name']
            ];
        }

        $response = [];
        foreach ($categories as $cat) {
            $cat_key = $normalize_category($cat['value']);
            $response[$cat['value']] = isset($items_by_category[$cat_key]) ? $items_by_category[$cat_key] : [];
        }

        echo json_encode([
            'success' => true,
            'branch_id' => $effective_branch_id,
            'categories' => $response
        ]);
        break;


    case 'add-post':
        // if($user->roleid != 0){
            // r2(U."dashboard",'e',$_L['You do not have permission']);
        // }
        $name = trim(_post('name'));
        $sales_price = Finance::amount_fix(_post('sales_price'));
        if($sales_price === ''){
            $sales_price = 0; // optional for designs
        }
        $description = _post('description');
        $cloth_id    = _post('cloth_id');
        $branch_id   = _post('branch_id');
        $component_ids  = $_POST['component_id'] ?? [];
        $component_qtys = $_POST['component_qty'] ?? [];
        $categories = ORM::for_table('sys_items_category')->find_array();

        // $category_ids    = $_POST['category_id'] ?? [];
        // $category_prices = $_POST['category_price'] ?? [];
        
        /*echo '<pre>';
        var_dump($fabric_ids);
        var_dump($fabric_qty);
        var_dump($stone_ids);
        var_dump($stone_qty);
        var_dump($handwork_ids);
        var_dump($others_ids);
        echo '</pre>';exit;*/


        $msg = '';
       
        if($name == ''){
            $msg .= 'Item Name is required <br>';
        }
        // sale price optional for gift box; no validation
        // if(!empty($category_prices)){
        //     foreach($category_prices as $price) {
        //         if($price === '' || $price === null) {
        //             $msg .= 'Fill Each category price <br>';
        //             break; // Optional: Stop after the first missing price
        //         }
        //     }
        // }
        if($cloth_id == ''){
            $msg .= 'Cloth Type is required <br>';
        }

        if($user->roleid != 0){
            $branch_id = $user->branch_id;
        }
        if(empty($branch_id)){
            $msg .= 'Branch is required <br>';
        }
        
        $is_exist = ORM::for_table('sys_designs')->where('name', $name)->count();
        if($is_exist > 0)
        {
            $msg .= 'Gift Box Already exist <br>';
        }
        
        if($msg == ''){
            $d = ORM::for_table('sys_designs')->create();
            $d->name = $name;
            $d->price = $sales_price;
            $d->description = $description;
            $d->timestamp = date('Y-m-d H:i:s');
            
            // dynamic components per category
            foreach ($categories as $cat) {
                $val = $cat['value'];
                $ids = $component_ids[$val] ?? [];
                $qty = $component_qtys[$val] ?? [];
                $components = [];
                $count = max(count($ids), count($qty));
                for ($i = 0; $i < $count; $i++) {
                    if (!empty($ids[$i]) && isset($qty[$i]) && $qty[$i] !== '') {
                        $components[] = ['item_id' => $ids[$i], 'qty' => $qty[$i]];
                    }
                }
                $d->$val = json_encode($components);
            }
            
            $d->cloth_id = _post('cloth_id');
            $d->branch_id = $branch_id;
            
            // Handle Category Pricing
            // $categoryPricing = [];
            // foreach ($category_ids as $key => $category_id) {
            //     if (!empty($category_id) && isset($category_prices[$key])) {
            //         $categoryPricing[] = [
            //             'category_id' => $category_id,
            //             'price' => $category_prices[$key]
            //         ];
            //     }
            // }
            // $d->category_pricing = json_encode($categoryPricing);
            $d->category_pricing = [];
            
            $img_array = array();
            $count     = isset($_FILES['design_images']['name']) ? count($_FILES['design_images']['name']) : 0;

            for ($x = 0; $x < $count; $x++)
            {
                if(!empty($_FILES['design_images']["name"][$x]))
                {
                    $filename = 'ui/lib/imgs/design/'.time().$x.'.jpg';
                    $img_array[] = $filename;
                    move_uploaded_file($_FILES['design_images']["tmp_name"][$x], $filename);
                }
            }

            $d->image = json_encode($img_array);

            $d->save();
            $id = $d->id();
            _msglog('s',$_L['Item Added Successfully']);
            echo $id;
        }
        else{
            echo $msg;
        }
        break;



    case 'list-design':
        if(!has_access($user->roleid, 'products_n_services')) {
            r2(U."dashboard",'e',$_L['You do not have permission']);
        }
        $cloths = ORM::for_table('sys_cloths')->select('id')->select('name')->order_by_asc('name')->find_array();
        $ui->assign('cloths', $cloths);
        // Branch filter (admins get all, others get own)
        if ($user->roleid == 0) {
            $branches = ORM::for_table('sys_accounts')->order_by_asc('account')->find_array();
            $default_branch = 'all';
        } else {
            $branches = ORM::for_table('sys_accounts')->where('id', $user->branch_id)->find_array();
            $default_branch = $user->branch_id;
        }
        $ui->assign('branches', $branches);
        $ui->assign('default_branch', $default_branch);
        $ui->assign('xheader', Asset::css(['s2/css/select2.min','jquery.datatables', 'modal']));
        $ui->assign('xfooter', Asset::js(['s2/js/select2.min', 'datatables.min', 'modal']));
        $ui->assign('xfooter2', '<script type="text/javascript" src="' . $_theme . '/lib/design-list.js"></script>');
        $ui->display('manage/list-design.tpl');
        break;

    case 'list-design-datatable':
        if(!has_access($user->roleid, 'products_n_services')) {
            header('Content-Type: application/json');
            echo json_encode(['data' => [], 'recordsTotal' => 0, 'recordsFiltered' => 0]);
            break;
        }

        $request = $_REQUEST;

        $columns = [
            0 => 'd.id',
            1 => 'branch_name',
            2 => 'd.name',
            3 => 'd.timestamp',
            4 => 'd.id', // image
            5 => 'd.id'  // manage
        ];

        $length = isset($request['length']) ? (int)$request['length'] : 25;
        $start  = isset($request['start']) ? max(0, (int)$request['start']) : 0;
        $order_index = isset($request['order'][0]['column']) ? (int)$request['order'][0]['column'] : 0;
        $order_col = isset($columns[$order_index]) ? $columns[$order_index] : 'd.id';
        $order_dir = (isset($request['order'][0]['dir']) && strtolower($request['order'][0]['dir']) === 'asc') ? 'ASC' : 'DESC';

        // Total (respect branch restriction if non-admin / filter)
        $total_q = ORM::for_table('sys_designs');
        $request_branch = isset($request['branch_id']) ? trim($request['branch_id']) : '';
        if ($user->roleid != 0) {
            $total_q->where('branch_id', $user->branch_id);
        } elseif ($request_branch !== '' && $request_branch !== 'all') {
            $total_q->where('branch_id', $request_branch);
        }
        $totalData = (int) $total_q->count();

        // Use aliases + join so searching on cloth / branch name works without SQL errors
        $base_q = ORM::for_table('sys_designs')->table_alias('d')
            ->select('d.*')
            ->select('c.name', 'cloth_name')
            ->select_expr('COALESCE(b.alias, b.account, \'-\')', 'branch_name')
            ->left_outer_join('sys_cloths', ['d.cloth_id', '=', 'c.id'], 'c')
            ->left_outer_join('sys_accounts', ['d.branch_id', '=', 'b.id'], 'b');

        // filters
        // if (!empty($request['cloth_id'])) {
        //     $base_q->where('d.cloth_id', $request['cloth_id']);
        // }

        // if (!empty($request['min_price'])) {
        //     $base_q->where_gte('price', Finance::amount_fix($request['min_price']));
        // }

        // if (!empty($request['max_price'])) {
        //     $base_q->where_lte('price', Finance::amount_fix($request['max_price']));
        // }

        // branch filter
        $branch_id = isset($request['branch_id']) ? trim($request['branch_id']) : '';
        if ($user->roleid != 0) {
            $branch_id = $user->branch_id;
        }
        if ($branch_id !== '' && $branch_id !== 'all') {
            $base_q->where('d.branch_id', $branch_id);
        }

        if (!empty($request['search']['value'])) {
            $s = '%' . $request['search']['value'] . '%';
            $base_q->where_raw('(d.name LIKE ? OR d.description LIKE ? OR c.name LIKE ? OR b.alias LIKE ? OR b.account LIKE ?)', [$s, $s, $s, $s, $s]);
        }

        // if (!empty($request['design_name'])) {
        //     $n = '%' . $request['design_name'] . '%';
        //     $base_q->where_like('name', $n);
        // }

        $count_q = clone $base_q;
        $totalFiltered = (int) $count_q->count();

        $data_q = clone $base_q;
        $data_q->order_by_expr($order_col . ' ' . $order_dir);
        if ($length != -1) {
            $data_q->offset($start)->limit($length);
        }

        $rows = $data_q->find_array();

        $data = [];
        $serial = $start + 1;
        foreach ($rows as $r) {
            $branch_text = !empty($r['branch_name']) ? $r['branch_name'] : '-';

            $images = json_decode($r['image'], true);
            $first_img = (is_array($images) && !empty($images[0])) ? $images[0] : '';
            $img_link = $first_img ? '<a target="_blank" href="'.$first_img.'">View</a>' : '-';

            $qr_image = qrcode_generate('D-' . $r['id']);
            $qr_link = !empty($qr_image)
                ? '<a target="_blank" href="'. U .'qrcode/fetch&search='.basename($qr_image).'">View</a>'
                : '-';

            $actions = '<a href="'. U .'manage/view/'. $r['id'] .'" class="btn btn-success btn-xs"><i class="fa fa-bar-chart"></i> History</a> ';
            // if($user->roleid == 0){
                $actions .= '<a href="#" class="btn btn-primary btn-xs cedit" data-id="'.$r['id'].'"><i class="fa fa-pencil"></i> Edit</a> ';
                $actions .= '<a href="#" class="btn btn-danger btn-xs cdelete cdelete-design" data-id="'.$r['id'].'"><i class="fa fa-trash"></i> Delete</a>';
            // }

            $data[] = [
                $serial,
                htmlspecialchars($branch_text, ENT_QUOTES, 'UTF-8'),
                htmlspecialchars($r['name'], ENT_QUOTES, 'UTF-8'),
                $img_link,
                $qr_link,
                $actions
            ];
            $serial++;
        }

        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'draw' => intval($request['draw'] ?? 0),
            'recordsTotal' => intval($totalData),
            'recordsFiltered' => intval($totalFiltered),
            'data' => $data
        ]);

        break;


    case 'edit-post':
        // if($user->roleid != 0){
        //     r2(U."dashboard",'e',$_L['You do not have permission']);
        // }

    $id = _post('id');
    $name = _post('name');
    // $sales_price = Finance::amount_fix(_post('sales_price'));
    $description = _post('description');
    $branch_id   = _post('branch_id');
    $component_ids  = $_POST['component_id'] ?? [];
    $component_qtys = $_POST['component_qty'] ?? [];

    // $category_ids    = $_POST['category_id'] ?? [];
    // $category_prices = $_POST['category_price'] ?? [];
    
    $msg = '';
   
    if($name == ''){
        $msg .= 'Item Name is required <br>';
    }
    // if($sales_price == ''){
    //     $msg .= 'Sale price is required <br>';
    // }     
    // if(!empty($category_prices)){
    //     foreach($category_prices as $price) {
    //         if($price === '' || $price === null) {
    //             $msg .= 'Fill Each category price <br>';
    //             break; // Optional: Stop after the first missing price
    //         }
    //     }
    // }

    if($user->roleid != 0){
        $branch_id = $user->branch_id;
    }
    if(empty($branch_id)){
        $msg .= 'Branch is required <br>';
    }

    if($msg == ''){
        $d = ORM::for_table('sys_designs')->find_one($id);
        if(!$d){
            echo 'Gift Box not found';
            break;
        }
        $d->name = $name;
        // $d->price = $sales_price;
        $d->price = 0; // Sale price optional for designs
        $d->description = $description;
        $d->timestamp = date('Y-m-d H:i:s');

        foreach ($component_ids as $category => $ids) {
            $qty = $component_qtys[$category] ?? [];
            $components = [];
            $count = max(count($ids), count($qty));
            for ($i = 0; $i < $count; $i++) {
                if (!empty($ids[$i]) && isset($qty[$i]) && $qty[$i] !== '') {
                    $components[] = [
                        'item_id' => $ids[$i],
                        'qty'     => $qty[$i]
                    ];
                }
            }
            $d->$category = json_encode($components);
        }

        $d->cloth_id = _post('cloth_id');
        $d->branch_id = $branch_id;
        
        // Handle Category Pricing
        // $categoryPricing = [];
        // foreach ($category_ids as $key => $category_id) {
        //     if (!empty($category_id) && isset($category_prices[$key])) {
        //         $categoryPricing[] = [
        //             'category_id' => $category_id,
        //             'price' => $category_prices[$key]
        //         ];
        //     }
        // }
        // $d->category_pricing = json_encode($categoryPricing);
        $d->category_pricing = [];
        
        $old = $d->image;
        $img_array = array();
        $count     = isset($_FILES['design_images']['name']) ? count($_FILES['design_images']['name']) : 0;

        if($count > 0 && !empty($_FILES['design_images']["name"][0]))
        {
            for ($x = 0; $x < $count; $x++)
            {
                if(!empty($_FILES['design_images']["name"][$x]))
                {
                    $filename = 'ui/lib/imgs/design/'.time().$x.'.jpg';
                    $img_array[] = $filename;
                    move_uploaded_file($_FILES['design_images']["tmp_name"][$x], $filename);
                }
            }
                     
            $d->image = json_encode($img_array);

            foreach(json_decode($old, true) as $row)
            {
                unlink($row);
            }
        }
        $d->save();
        $id = $d->id();
        echo $id;
    }
    else{
        echo $msg;
    }    

        break;

				
    case 'delete':
        $id = $routes['2'];
        if($_app_stage == 'Demo'){
            r2(U . 'accounts/list', 'e', 'Sorry! Deleting Account is disabled in the demo mode.');
        }
        $d = ORM::for_table('sys_accounts')->find_one($id);
        if($d){
            $d->delete();
            r2(U . 'accounts/list', 's', $_L['account_delete_successful']);
        }

        break;

    case 'edit-form':

        $id = $routes['2'];
        $d = ORM::for_table('sys_designs')->find_one($id);
        if($d)
        {
            $categories = ORM::for_table('sys_items_category')->find_array();
            $category_items = [];
            $components = [];
            // $prefill_branch_id = ($user->roleid == 0) ? (string) $d->branch_id : (string) $user->branch_id;
            foreach ($categories as $cat) {
                $val = $cat['value'];
                $items_q = ORM::for_table('sys_items')
                    ->where('type', 'Product')
                    ->where('product_category', $val);
                // if ($prefill_branch_id !== '') {
                //     $items_q->where('branch_id', $prefill_branch_id);
                // }
                $category_items[$val] = $items_q->find_array();
                $components[$val] = json_decode($d[$val], true) ?: [];
            }
            $ui->assign('categories', $categories);
            $ui->assign('category_items', $category_items);
            $ui->assign('components', $components);

            $cloths = ORM::for_table('sys_cloths')->find_many();
            $ui->assign('cloths', $cloths);            
            $ui->assign('d',$d);

            // Branches (admins see all; staff only their branch)
            if ($user->roleid == 0) {
                $branches = ORM::for_table('sys_accounts')->order_by_asc('account')->find_array();
            } else {
                $branches = ORM::for_table('sys_accounts')->where('id', $user->branch_id)->find_array();
            }
            $ui->assign('branches', $branches);

            // Fetch category employees
            $categoryEmployees = ORM::for_table('category_employee')->select('id')->select('name')->find_array();
            $ui->assign('category_employees', $categoryEmployees);
    
            // // Decode category pricing JSON
            $categoryPricing = json_decode($d->category_pricing, true) ?: [];
            $ui->assign('category_pricing', $categoryPricing);
            $ui->display('manage/edit-design.tpl');
        }
        else
        {
            echo 'not found';
        }

        break;

        case 'edit-form-stock':
            $id = $routes['2'];
            $d = ORM::for_table('sys_items')->find_one($id);
            if($d)
            {
                $ui->assign('d',$d);
                $ui->display('edit-ps-stock.tpl');
            }
            
        break;        

    case 'post':

        break;

    case 'ajax-delete':
        header('Content-Type: application/json; charset=utf-8');

        // if($user->roleid != 0){
        //     echo json_encode(['success' => false, 'message' => $_L['You do not have permission']]);
        //     break;
        // }

        $id = _post('id');
        if(empty($id)){
            echo json_encode(['success' => false, 'message' => 'Invalid design id']);
            break;
        }

        $design = ORM::for_table('sys_designs')->find_one($id);
        if(!$design){
            echo json_encode(['success' => false, 'message' => 'Gift Box not found']);
            break;
        }

        $images = json_decode($design->image, true);
        if(is_array($images)){
            foreach($images as $img){
                if(!empty($img) && file_exists($img)){
                    @unlink($img);
                }
            }
        }

        $design->delete();

        _log('Gift Box Deleted: '.$design->name.' [ID: '.$id.']','Admin',$user['id']);

        echo json_encode(['success' => true, 'message' => 'Gift Box deleted successfully']);
        break;

    default:
        echo 'action not defined';
}
