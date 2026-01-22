<?php
_auth();
$ui->assign('_application_menu', 'branches');
$ui->assign('_title', 'Branches - ' . $config['CompanyName']);
$ui->assign('_st', 'Branches');

$action = $routes['1'] ?? 'list';
$user = User::_info();
$ui->assign('user', $user);

// Super admin only
if (has_access($user->roleid, 'branches') == false) {
    r2(U . 'dashboard', 'e', $_L['You do not have permission']);
}

switch ($action) {
    case 'list':
        $search = trim(_get('q', ''));

        $q = ORM::for_table('sys_accounts');

        if ($search !== '') {
            $like = '%' . $search . '%';
            $q->where_raw(
                '(account LIKE :q OR alias LIKE :q OR description LIKE :q OR email LIKE :q)',
                ['q' => $like]
            );
        }

        $branches = $q->order_by_asc('account')->find_array();

        $ui->assign('search', $search);
        $ui->assign('branches', $branches);
        $ui->assign('xfooter', "
<script>
    $(function() {
        $('.cdelete').off('click').on('click', function(e) {
            e.preventDefault();
            var id = this.id.replace('bid', '');
            var lan_msg = $('#_lan_are_you_sure').val();
            bootbox.confirm(lan_msg, function(result) {
                if(result){
                    var _url = $('#_url').val();
                    window.location.href = _url + 'branches/delete/' + id + '/';
                }
            });
        });
    });
</script>
");
        $ui->display('branches/list.tpl');
        break;

    case 'add':
        $ui->assign('branch', null);
        $ui->display('branches/form.tpl');
        break;

    case 'add-post':
        $account        = _post('account');
        $alias          = _post('alias');
        $description    = _post('description');
        $address        = _post('address');
        $contact_person = _post('contact_person');
        $contact_phone  = _post('contact_phone');
        $email          = _post('email');
        $gstin          = _post('gstin');
        $pan            = _post('pan');
        $bank_name      = _post('bank_name');
        $account_number = _post('account_number');
        $account_type   = _post('account_type');
        $ifsc           = _post('ifsc');
        $status         = _post('status', 'Active');
        $company_logo   = '';
        $company_stamp  = '';

        $msg = '';

        if (Validator::Length($account, 100, 2) == false) {
            $msg .= $_L['account_title_length_error'] . '<br>';
        }

        if ($email && !Validator::Email($email)) {
            $msg .= $_L['Invalid Email'] . '<br>';
        }

        $existing = ORM::for_table('sys_accounts')->where('account', $account)->find_one();
        if ($existing) {
            $msg .= $_L['account_already_exist'] . '<br>';
        }

        // Handle logo upload
        if (isset($_FILES['company_logo']['name']) && $_FILES['company_logo']['name'] !== '') {
            $validExtensions = ['jpeg', 'jpg', 'png', 'gif'];
            $temporary = explode('.', $_FILES['company_logo']['name']);
            $file_extension = strtolower(end($temporary));

            if (
                in_array($file_extension, $validExtensions) &&
                in_array($_FILES['company_logo']['type'], ['image/png', 'image/jpg', 'image/jpeg', 'image/gif']) &&
                $_FILES['company_logo']['size'] < 1000000
            ) {
                $ext = $file_extension === 'jpeg' ? 'jpg' : $file_extension;
                $company_logo = strtotime('now') . '_logo.' . $ext;
                move_uploaded_file($_FILES['company_logo']['tmp_name'], 'application/storage/system/' . $company_logo);
            } else {
                $msg .= 'Invalid logo file. Use png/jpg/gif under 1MB.<br>';
            }
        }

        // Handle stamp upload
        if (isset($_FILES['company_stamp']['name']) && $_FILES['company_stamp']['name'] !== '') {
            $validExtensions = ['jpeg', 'jpg', 'png', 'gif'];
            $temporary = explode('.', $_FILES['company_stamp']['name']);
            $file_extension = strtolower(end($temporary));

            if (
                in_array($file_extension, $validExtensions) &&
                in_array($_FILES['company_stamp']['type'], ['image/png', 'image/jpg', 'image/jpeg', 'image/gif']) &&
                $_FILES['company_stamp']['size'] < 1000000
            ) {
                $ext = $file_extension === 'jpeg' ? 'jpg' : $file_extension;
                $company_stamp = strtotime('now') . '_stamp.' . $ext;
                move_uploaded_file($_FILES['company_stamp']['tmp_name'], 'application/storage/system/' . $company_stamp);
            } else {
                $msg .= 'Invalid stamp file. Use png/jpg/gif under 1MB.<br>';
            }
        }

        if ($msg !== '') {
            r2(U . 'branches/add', 'e', $msg);
        }

        $branch = ORM::for_table('sys_accounts')->create();
        $branch->account        = $account;
        $branch->alias          = $alias;
        $branch->description    = $description;
        $branch->address        = $address;
        $branch->contact_person = $contact_person;
        $branch->contact_phone  = $contact_phone;
        $branch->email          = $email;
        $branch->gstin          = $gstin;
        $branch->pan            = $pan;
        $branch->bank_name      = $bank_name;
        $branch->account_number = $account_number;
        $branch->account_type   = $account_type;
        $branch->ifsc           = $ifsc;
        $branch->status         = $status;
        $branch->company_logo   = $company_logo;
        $branch->company_stamp  = $company_stamp;
        $branch->balance        = 0.00;
        $branch->created        = date('Y-m-d');
        $branch->save();

        r2(U . 'branches/list', 's', $_L['account_created_successfully']);
        break;

    case 'edit':
        $id = (int) $routes['2'];
        $branch = ORM::for_table('sys_accounts')->find_one($id);

        if (!$branch) {
            r2(U . 'branches/list', 'e', $_L['Account_Not_Found']);
        }

        $ui->assign('branch', $branch);
        $ui->display('branches/form.tpl');
        break;

    case 'edit-post':
        $id             = (int) _post('id');
        $account        = _post('account');
        $alias          = _post('alias');
        $description    = _post('description');
        $address        = _post('address');
        $contact_person = _post('contact_person');
        $contact_phone  = _post('contact_phone');
        $email          = _post('email');
        $gstin          = _post('gstin');
        $pan            = _post('pan');
        $bank_name      = _post('bank_name');
        $account_number = _post('account_number');
        $account_type   = _post('account_type');
        $ifsc           = _post('ifsc');
        $status         = _post('status', 'Active');
        $company_logo   = '';
        $company_stamp  = '';

        $branch = ORM::for_table('sys_accounts')->find_one($id);

        if (!$branch) {
            r2(U . 'branches/list', 'e', $_L['Account_Not_Found']);
        }

        $msg = '';

        if (Validator::Length($account, 100, 2) == false) {
            $msg .= $_L['account_title_length_error'] . '<br>';
        }

        if ($email && !Validator::Email($email)) {
            $msg .= $_L['Invalid Email'] . '<br>';
        }

        $duplicate = ORM::for_table('sys_accounts')
            ->where('account', $account)
            ->where_not_equal('id', $id)
            ->find_one();

        if ($duplicate) {
            $msg .= $_L['account_already_exist'] . '<br>';
        }

        // Handle logo upload (retain existing if none uploaded)
        $company_logo = $branch->company_logo;
        if (isset($_FILES['company_logo']['name']) && $_FILES['company_logo']['name'] !== '') {
            $validExtensions = ['jpeg', 'jpg', 'png', 'gif'];
            $temporary = explode('.', $_FILES['company_logo']['name']);
            $file_extension = strtolower(end($temporary));

            if (
                in_array($file_extension, $validExtensions) &&
                in_array($_FILES['company_logo']['type'], ['image/png', 'image/jpg', 'image/jpeg', 'image/gif']) &&
                $_FILES['company_logo']['size'] < 1000000
            ) {
                $ext = $file_extension === 'jpeg' ? 'jpg' : $file_extension;
                $company_logo = strtotime('now') . '_logo.' . $ext;
                move_uploaded_file($_FILES['company_logo']['tmp_name'], 'application/storage/system/' . $company_logo);
            } else {
                $msg .= 'Invalid logo file. Use png/jpg/gif under 1MB.<br>';
            }
        }

        // Handle stamp upload (retain existing if none uploaded)
        $company_stamp = $branch->company_stamp;
        if (isset($_FILES['company_stamp']['name']) && $_FILES['company_stamp']['name'] !== '') {
            $validExtensions = ['jpeg', 'jpg', 'png', 'gif'];
            $temporary = explode('.', $_FILES['company_stamp']['name']);
            $file_extension = strtolower(end($temporary));

            if (
                in_array($file_extension, $validExtensions) &&
                in_array($_FILES['company_stamp']['type'], ['image/png', 'image/jpg', 'image/jpeg', 'image/gif']) &&
                $_FILES['company_stamp']['size'] < 1000000
            ) {
                $ext = $file_extension === 'jpeg' ? 'jpg' : $file_extension;
                $company_stamp = strtotime('now') . '_stamp.' . $ext;
                move_uploaded_file($_FILES['company_stamp']['tmp_name'], 'application/storage/system/' . $company_stamp);
            } else {
                $msg .= 'Invalid stamp file. Use png/jpg/gif under 1MB.<br>';
            }
        }

        if ($msg !== '') {
            r2(U . 'branches/edit/' . $id, 'e', $msg);
        }

        $branch->account        = $account;
        $branch->alias          = $alias;
        $branch->description    = $description;
        $branch->address        = $address;
        $branch->contact_person = $contact_person;
        $branch->contact_phone  = $contact_phone;
        $branch->email          = $email;
        $branch->gstin          = $gstin;
        $branch->pan            = $pan;
        $branch->bank_name      = $bank_name;
        $branch->account_number = $account_number;
        $branch->account_type   = $account_type;
        $branch->ifsc           = $ifsc;
        $branch->status         = $status;
        $branch->company_logo   = $company_logo;
        $branch->company_stamp  = $company_stamp;
        $branch->save();

        r2(U . 'branches/list', 's', $_L['account_updated_successfully']);
        break;

    case 'delete':
        $id = (int) $routes['2'];
        $branch = ORM::for_table('sys_accounts')->find_one($id);

        if (!$branch) {
            r2(U . 'branches/list', 'e', $_L['Account_Not_Found']);
        }

        $contactsCount = ORM::for_table('crm_accounts')->where('branch_id', $id)->count();
        $invoiceCount  = ORM::for_table('sys_invoices')->where('company_id', $id)->count();
        $txCount       = ORM::for_table('sys_transactions')->where('branch_id', $id)->count();

        if ($contactsCount || $invoiceCount || $txCount) {
            $message = 'Branch cannot be deleted because it is linked to ';
            $reasons = [];
            if ($contactsCount) {
                $reasons[] = $contactsCount . ' contact(s)';
            }
            if ($invoiceCount) {
                $reasons[] = $invoiceCount . ' invoice(s)';
            }
            if ($txCount) {
                $reasons[] = $txCount . ' transaction(s)';
            }
            $message .= implode(', ', $reasons) . '.';
            r2(U . 'branches/list', 'e', $message);
        }

        $branch->delete();
        r2(U . 'branches/list', 's', $_L['account_delete_successful']);
        break;

    default:
        echo 'action not defined';
}
