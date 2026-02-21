<?php

_auth();

$ui->assign('_application_menu', 'invoices');
$ui->assign('_st', 'Return Invoice');
$ui->assign('_title', 'Return Invoice - ' . $config['CompanyName']);

$action = isset($routes['1']) ? $routes['1'] : 'list';
$user   = User::_info();
$ui->assign('user', $user);

switch ($action) {

    // -------------------------------------------------------------------------
    case 'list':
        if(!has_access($user->roleid, 'sales')) {
            r2(U."dashboard",'e',$_L['You do not have permission']);
        }

        $paginator = Paginator::bootstrap('sys_credit_notes');
        $creditNotes = ORM::for_table('sys_credit_notes')
            ->offset($paginator['startpoint'])
            ->limit($paginator['limit'])
            ->order_by_desc('id')
            ->find_many();

        $ui->assign('d', $creditNotes);
        $ui->assign('paginator', $paginator);
        $ui->assign('xheader', Asset::css(array('footable/css/footable.core.min')));
        $ui->assign('xfooter', Asset::js(array('footable/js/footable.all.min','numeric')));
        $ui->assign('xjq', '$(".footable").footable();$(".amount").autoNumeric("init",{aSign:"'. $config['currency_code'].' ",pSign:"'.$config['currency_symbol_position'].'",aDec:"'.$config['dec_point'].'",aSep:"'.$config['thousands_sep'].'",aPad:'.$config['currency_decimal_digits'].'});');
        $ui->display('creditnotes-list.tpl');
        break;

    // -------------------------------------------------------------------------
    case 'add':
        if(!has_access($user->roleid, 'sales')) {
            r2(U."dashboard",'e',$_L['You do not have permission']);
        }

        $invoice_id = isset($routes[2]) ? (int)$routes[2] : 0;
        if($invoice_id === 0){
            r2(U."invoices/list/filter/",'e','Return Invoice must be created from an invoice.');
        }

        $invoice = ORM::for_table('sys_invoices')->find_one($invoice_id);
        if(!$invoice){
            r2(U."invoices/list/filter/",'e','Invoice not found');
        }

        $customer  = ORM::for_table('crm_accounts')->find_one($invoice->userid);
        if(!$customer){
            r2(U."invoices/list/filter/",'e','Customer not found');
        }

        $taxes      = ORM::for_table('sys_tax')->order_by_asc('rate')->find_array();
        $branches   = ORM::for_table('sys_accounts')->select_many('id','alias','account')->order_by_asc('id')->find_array();

        // Fetch invoice items to prefill
        $invoice_items = ORM::for_table('sys_invoiceitems')->where('invoiceid',$invoice_id)->order_by_asc('id')->find_array();

        // Compute already returned qty per product for this invoice
        $returned_map = array();
        $existing_returns = ORM::for_table('sys_credit_notes')->table_alias('cn')
            ->join('sys_creditnoteitems','cni.creditnoteid = cn.id','cni')
            ->where('cn.original_invoice_id',$invoice_id)
            ->select('cni.product_id')
            ->select_expr('SUM(cni.qty)','returned_qty')
            ->group_by('cni.product_id')
            ->find_array();
        foreach($existing_returns as $er){
            $returned_map[(int)$er['product_id']] = (float)$er['returned_qty'];
        }

        $ui->assign('invoice', $invoice);
        $ui->assign('customer', $customer);
        $ui->assign('taxes', $taxes);
        $ui->assign('branches', $branches);
        $ui->assign('invoice_items', $invoice_items);
        $ui->assign('returned_map', $returned_map);
        // total paid against invoice
        $paid_total = ORM::for_table('sys_transactions')->where('iid',$invoice_id)->where('type','Income')->sum('cr');
        $paid_total = $paid_total ?: 0;
        $ui->assign('paid_total', $paid_total);
        $refund_account_name = get_branch_name($invoice->company_id,'alias');
        if(!$refund_account_name){
            $refund_account_name = get_branch_name($invoice->company_id,'account');
        }
        $ui->assign('refund_account_name', $refund_account_name);
        $ui->assign('idate', date('Y-m-d'));

        $ui->assign('xheader', Asset::css(array('s2/css/select2.min','dp/dist/datepicker.min')));
        $ui->assign('xfooter', Asset::js(array('s2/js/select2.min','s2/js/i18n/'.lan(),'dp/dist/datepicker.min','dp/i18n/'.$config['language'],'numeric','creditnote')));
        $ui->assign('xjq', '$("#creditnote_date").datepicker({format:"yyyy-mm-dd"});
            if(typeof initCreditNoteCalc === "function"){ initCreditNoteCalc(); }');
        $ui->display('creditnote-add.tpl');
        break;

    // -------------------------------------------------------------------------
    case 'save':
    case 'add-post':
        if(!has_access($user->roleid, 'sales')) {
            r2(U."dashboard",'e',$_L['You do not have permission']);
        }
        try{

        $original_invoice_id = (int) _post('original_invoice_id');
        if($original_invoice_id <= 0){
            echo 'Invoice is required.';
            break;
        }

        $invoice = ORM::for_table('sys_invoices')->find_one($original_invoice_id);
        if(!$invoice){
            echo 'Invoice not found.';
            break;
        }

        $cid   = $invoice->userid;
        $idate = _post('creditnote_date');
        $notes = _post('notes');
        $discount_amount = _post('discount_amount','0');
        $currency_id = $invoice->currency;

        $msg = '';

        if($cid == ''){
            $msg .= $_L['Select Contact'].' <br>';
        }

        $desc_arr   = isset($_POST['item_description']) ? $_POST['item_description'] : array();
        $qty_arr    = isset($_POST['item_qty']) ? $_POST['item_qty'] : array();
        $price_arr  = isset($_POST['item_price']) ? $_POST['item_price'] : array();
        $tax_arr    = isset($_POST['item_tax']) ? $_POST['item_tax'] : array();
        $product_arr= isset($_POST['item_product']) ? $_POST['item_product'] : array();
        $unit_arr   = isset($_POST['item_unit']) ? $_POST['item_unit'] : array();
        $branch_arr = isset($_POST['item_branch']) ? $_POST['item_branch'] : array();
        $invoice_item_arr = isset($_POST['invoice_item_id']) ? $_POST['invoice_item_id'] : array();

        if($msg != ''){
            echo $msg;
            break;
        }

        $account = get_type_by_id('crm_accounts','id',$cid,'account');
        $customer_branch = $invoice->company_id ?: (get_type_by_id('crm_accounts','id',$cid,'branch_id') ?: 0);

        $currency_symbol = $invoice->currency_symbol ?: $config['currency_code'];
        $currency_prefix = $invoice->currency_prefix ?: $config['currency_code'];
        $currency_suffix = $invoice->currency_suffix ?: '';
        $currency_rate   = $invoice->currency_rate ?: 1.0000;
        if(!$currency_rate){
            $currency_rate = 1.0000;
        }

        $subtotal = 0.00;
        $taxTotal = 0.00;
        $total    = 0.00;

        // Build invoice items map for validation
        $inv_items = ORM::for_table('sys_invoiceitems')->where('invoiceid',$original_invoice_id)->find_array();
        $inv_map = array();
        foreach($inv_items as $inv_it){
            $inv_map[$inv_it['id']] = $inv_it;
        }
        // already returned map
        $returned_map = array();
        $existing_returns = ORM::for_table('sys_credit_notes')->table_alias('cn')
            ->join('sys_creditnoteitems','cni.creditnoteid = cn.id','cni')
            ->where('cn.original_invoice_id',$original_invoice_id)
            ->select('cni.product_id')
            ->select_expr('SUM(cni.qty)','returned_qty')
            ->group_by('cni.product_id')
            ->find_array();
        foreach($existing_returns as $er){
            $returned_map[(int)$er['product_id']] = (float)$er['returned_qty'];
        }

        $rows = array();
        foreach($desc_arr as $k => $description){
            $invoice_item_id = isset($invoice_item_arr[$k]) ? (int)$invoice_item_arr[$k] : 0;
            if($invoice_item_id === 0 || !isset($inv_map[$invoice_item_id])){
                $msg .= 'Invalid invoice item reference.<br>';
                continue;
            }

            $inv_it = $inv_map[$invoice_item_id];

            $qty   = isset($qty_arr[$k]) ? Finance::amount_fix($qty_arr[$k]) : 0;
            // cap qty
            $already_ret = $returned_map[(int)$inv_it['product_id']] ?? 0.0;
            $available_qty = $inv_it['qty'] - $already_ret;
            if($qty < 0){
                $msg .= 'Quantity cannot be negative.<br>';
            }
            elseif($qty > $available_qty + 0.0001){
                $msg .= 'Return qty exceeds available for item '.$inv_it['description'].' (available '.$available_qty.').<br>';
            }

            // use invoice price and tax to avoid tampering
            $price = Finance::amount_fix($inv_it['amount']);
            $tax_rate = Finance::amount_fix($inv_it['taxrate']);
            $unit = $inv_it['unit'] ?: 'qty';
            $branch_for_item = !empty($inv_it['branch_id']) ? $inv_it['branch_id'] : $customer_branch;

            $line_sub = $qty * $price;
            $line_tax = ($line_sub * $tax_rate) / 100;
            $line_total = $line_sub + $line_tax;

            $subtotal += $line_sub;
            $taxTotal += $line_tax;
            $total    += $line_total;

            // skip zero-qty lines to avoid extra creditnoteitems
            if($qty <= 0){
                continue;
            }

            $rows[] = array(
                'invoice_item_id' => $invoice_item_id,
                'description' => $description ?: $inv_it['description'],
                'qty'         => $qty,
                'price'       => $price,
                'tax_rate'    => $tax_rate,
                'tax_amount'  => $line_tax,
                'total'       => $line_total,
                'product_id'  => isset($product_arr[$k]) ? (int)$product_arr[$k] : (int)$inv_it['product_id'],
                'unit'        => $unit,
                'branch_id'   => $branch_for_item
            );
        }

        if($msg != ''){
            echo $msg;
            break;
        }

        $discount_amount = Finance::amount_fix($discount_amount ?: 0);
        $subtotal_after_discount = $subtotal - $discount_amount;
        if($subtotal_after_discount < 0){
            $subtotal_after_discount = 0;
        }
        $grand_total = $subtotal_after_discount + $taxTotal;
        if($grand_total <= 0){
            echo 'Return Invoice total must be greater than zero.';
            break;
        }
        $existing_cn_total = ORM::for_table('sys_credit_notes')->where('original_invoice_id',$original_invoice_id)->sum('total');
        $existing_cn_total = $existing_cn_total ?: 0;
        if(($existing_cn_total + $grand_total) - $invoice->subtotal > 0.0001){
            echo 'Credit note exceeds remaining invoice amount.';
            break;
        }

        // default refund amount if invoice had payments
        $paid_total = ORM::for_table('sys_transactions')->where('iid',$original_invoice_id)->where('type','Income')->sum('cr');
        $paid_total = $paid_total ?: 0;
        $auto_refund_amount = min($paid_total, $grand_total);

        // create credit note
        $cn_number = ORM::for_table('sys_credit_notes')->max('id');
        $cn_number = (int)$cn_number + 1;
        $creditnotenum = 'R-INV'.sprintf('%05d',$cn_number);

        $cn = ORM::for_table('sys_credit_notes')->create();
        $cn->userid = $cid;
        $cn->account = $account;
        $cn->creditnotenum = $creditnotenum;
        $cn->original_invoice_id = $original_invoice_id ?: 0;
        $cn->date = $idate ?: date('Y-m-d');
        $cn->subtotal = Finance::amount_fix($subtotal);
        $cn->discount = $discount_amount;
        $cn->taxamt = Finance::amount_fix($taxTotal);
        $cn->total = Finance::amount_fix($grand_total);
        $cn_status = (($existing_cn_total + $grand_total) >= ($invoice->subtotal - 0.0001)) ? 'Closed' : 'Open';
        $cn->status = $cn_status;
        $cn->notes = $notes;
        $cn->currency = (int)$currency_id;
        $cn->currency_symbol = $currency_symbol;
        $cn->currency_prefix = $currency_prefix;
        $cn->currency_suffix = $currency_suffix;
        $cn->currency_rate = $currency_rate;
        $cn->company_id = $customer_branch;
        $cn->branch_id = $customer_branch;
        $cn->created_by = (int)$user['id'];
        $cn->created_at = date('Y-m-d H:i:s');
        $cn->updated_at = date('Y-m-d H:i:s');
        $cn->save();

        $creditnote_id = $cn->id();

        // ensure invoice_item_id column exists (avoids SQL error on insert)
        $hasInvoiceItemId = ORM::for_table('sys_creditnoteitems')->raw_query("SHOW COLUMNS FROM sys_creditnoteitems LIKE 'invoice_item_id'")->find_one();
        if(!$hasInvoiceItemId){
            ORM::execute("ALTER TABLE `sys_creditnoteitems` ADD `invoice_item_id` INT(11) NOT NULL DEFAULT '0' AFTER `unit`");
        }

        // save items + stock reversal
        foreach($rows as $row){
            $it = ORM::for_table('sys_creditnoteitems')->create();
            $it->creditnoteid = $creditnote_id;
            $it->userid       = $cid;
            $it->itemcode     = '';
            $it->description  = $row['description'];
            $it->qty          = $row['qty'];
            $it->amount       = $row['price'];
            $it->taxrate      = $row['tax_rate'];
            $it->taxamount    = $row['tax_amount'];
            $it->total        = $row['total'];
            $it->product_id   = $row['product_id'];
            $it->branch_id    = $row['branch_id'];
            $it->unit         = $row['unit'];
            $it->invoice_item_id = $row['invoice_item_id'];
            $it->created_at   = date('Y-m-d H:i:s');
            $it->updated_at   = date('Y-m-d H:i:s');
            $it->save();

            if($row['product_id'] > 0 && $row['qty'] > 0){
                $stock_qty = $row['qty'];
                if(strtolower($row['unit']) === 'tola'){
                    $stock_qty = tola_to_grams($row['qty']);
                }
                stock_record($row['product_id'], $stock_qty, 'credit', $creditnote_id, '', '', '', $row['branch_id'], '');
            }
        }

        // Optional refund record
        $refund_amount = Finance::amount_fix(_post('refund_amount','0'));
        $refund_account_id = _post('refund_account_id') ?: $invoice->company_id;

        if($refund_amount <= 0 && $auto_refund_amount > 0){
            $refund_amount = $auto_refund_amount;
        }
        if($refund_amount > 0 && $refund_account_id != ''){
            $refund_account = ORM::for_table('sys_accounts')->find_one($refund_account_id);
            if($refund_account){
                $nbal = $refund_account->balance - $refund_amount;
                $refund_account->balance = $nbal;
                $refund_account->save();

                $t = ORM::for_table('sys_transactions')->create();
                $t->account = $refund_account->account;
                $t->branch_id = $refund_account_id;
                $t->type = 'Refund';
                $t->payerid = $cid;
                $t->amount = $refund_amount;
                $t->category = 'Customer Refund';
                $t->method = _post('refund_method') ?: 'Cash';
                $t->ref = _post('refund_ref');
                $t->tags = '';
                $t->description = 'Refund for Return Invoice '.$creditnotenum;
                $t->date = _post('refund_date') ?: date('Y-m-d');
                $t->dr = $refund_amount;
                $t->cr = '0.00';
                $t->bal = $nbal;
                $t->iid = 0;
                $t->creditnote_id = $creditnote_id;
                $t->status = 'Cleared';
                $t->tax = '0.00';
                $t->save();
            }
        }

        // Sync customer balance to include credit notes
        if(function_exists('sync_customer_balance')){
            sync_customer_balance($cid);
        }

        Event::trigger('creditnotes/created/'.$creditnote_id);

            r2(U.'creditnotes/view/'.$creditnote_id,'s','Credit note created');
        } catch (Exception $e){
            r2(U.'creditnotes/add/'.$original_invoice_id,'e','Error: '.$e->getMessage());
        }
        break;

    // -------------------------------------------------------------------------
    case 'view':
        if(!has_access($user->roleid, 'sales')) {
            r2(U."dashboard",'e',$_L['You do not have permission']);
        }

        $id = $routes['2'];
        $cn = ORM::for_table('sys_credit_notes')->find_one($id);
        if(!$cn){
            r2(U.'creditnotes/list/','e','Credit note not found');
        }

        $items = ORM::for_table('sys_creditnoteitems')->where('creditnoteid',$id)->find_many();
        $customer = ORM::for_table('crm_accounts')->find_one($cn->userid);
        $original_invoice = null;
        if(!empty($cn->original_invoice_id)){
            $original_invoice = ORM::for_table('sys_invoices')->find_one($cn->original_invoice_id);
        }

        $ui->assign('cn',$cn);
        $ui->assign('items',$items);
        $ui->assign('customer',$customer);
        $ui->assign('original_invoice',$original_invoice);
        $ui->assign('xheader', Asset::css(array('numeric')));
        $ui->assign('xfooter', Asset::js(array('numeric')));
        $ui->assign('xjq','$(".amount").autoNumeric("init",{aSign:"'. $config['currency_code'].' ",pSign:"'.$config['currency_symbol_position'].'",aDec:"'.$config['dec_point'].'",aSep:"'.$config['thousands_sep'].'",aPad:'.$config['currency_decimal_digits'].'});');
        $ui->display('creditnote-view.tpl');
        break;

    default:
        echo 'action not defined';
}
