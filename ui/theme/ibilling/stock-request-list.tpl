{include file="sections/header.tpl"}

<div class="row" id="application_ajaxrender">
    <div class="col-md-12">
        <div class="panel panel-default">
            <div class="panel-heading clearfix">
                <h3 class="panel-title pull-left">Stock Requests</h3>
                <div class="pull-right">
                    <a href="{$_url}ps/request_list/&status=pending" class="btn btn-default btn-xs {if $status_filter=='pending'}active{/if}">Pending</a>
                    <a href="{$_url}ps/request_list/&status=fulfilled" class="btn btn-default btn-xs {if $status_filter=='fulfilled'}active{/if}">Fulfilled</a>
                    <a href="{$_url}ps/request_list/&status=rejected" class="btn btn-default btn-xs {if $status_filter=='rejected'}active{/if}">Rejected</a>
                    <a href="{$_url}ps/request_list/&status=all" class="btn btn-default btn-xs {if $status_filter=='all'}active{/if}">All</a>
                </div>
            </div>
            <div class="panel-body">
                <table class="table table-bordered sys_table" id="requestsTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Product</th>
                            <th>To Branch</th>
                            <th>Requested Qty</th>
                            <th>Shipped Qty</th>
                            <th>Status</th>
                            <th>Requested By</th>
                            <th>Note</th>
                            <th>Created</th>
                            {if ($is_super|default:false)}<th>Actions</th>{/if}
                        </tr>
                    </thead>
                    <tbody>
                        {assign var="i" value=1}
                        {foreach $requests as $r}
                            <tr data-id="{$r.id}" data-item="{$r.item_id}" data-requested="{$r.requested_qty}" data-to="{$r.to_branch_id}" data-shipped="{$r.shipped_qty}" data-status="{$r.status}">
                                <td></td>
                                <td>{get_type_by_id('sys_items','id',$r.item_id,'name')}</td>
                                <td>{get_branch_name($r.to_branch_id, alias)}</td>
                                <td>{$r.requested_qty}</td>
                                <td>{$r.shipped_qty}</td>
                                <td><span class="label label-{if $r.status=='pending'}warning{elseif $r.status=='fulfilled'}success{elseif $r.status=='rejected'}danger{else}default{/if}">{$r.status|capitalize}</span></td>
                                <td>{get_type_by_id('sys_users','id',$r.requested_by,'fullname')}</td>
                                <td>{if $r.note}{$r.note}{else}-{/if}</td>
                                <td>{date('Y-m-d H:i', strtotime($r.created_at))}</td>
                                {if ($is_super|default:false)}
                                    <td>
                                        {if $r.status=='pending'}
                                            <button class="btn btn-xs btn-success btn-fulfill" title="Fulfill" {if isset($r.branch_stock_json)}data-branchstock='{$r.branch_stock_json}'{/if}><i class="fa fa-check"></i></button>
                                            <button class="btn btn-xs btn-danger btn-reject" title="Reject"><i class="fa fa-times"></i></button>
                                        {else}
                                            <span class="text-muted">-</span>
                                        {/if}
                                    </td>
                                {/if}
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<select id="branch_options_template" style="display:none;">
    {foreach $branches as $branch}
        <option value="{$branch.id}">{$branch.account}</option>
    {/foreach}
</select>

{include file="sections/footer.tpl"}

<script>
{literal}
$(function(){
    var createdColIndex = 8; // both views have Created as 9th column (0-based index 8)
    $('#requestsTable').DataTable({
        order: [[createdColIndex,'desc']],
        pageLength: 25,
        columnDefs: [
            {
                targets: 0, // serial #
                orderable: false,
                searchable: false,
                render: function (data, type, row, meta) {
                    return meta.row + 1;
                }
            }
        ]
    });

    var $modal = $('#ajax-modal');
    // build branch name map from template options
    var branchOptionsTemplate = $('#branch_options_template option');
    var branchMap = {};
    branchOptionsTemplate.each(function(){
        var id = $(this).val();
        branchMap[id] = $(this).text();
    });
    var _url = $('#_url').val();

    // Fulfill
    $(document).on('click','.btn-fulfill', function(e){
        e.preventDefault();
        var $tr = $(this).closest('tr');
        var reqId = $tr.data('id');
        var requestedQty = $tr.data('requested');
        var toBranch = $tr.data('to');
        var toBranchName = $tr.find('td:nth-child(3)').text();
        var branchStock = {};
        try { branchStock = JSON.parse($tr.find('.btn-fulfill').attr('data-branchstock')) || {}; } catch(e){}

        // compose options with availability
        var branchOptions = '';
        branchOptionsTemplate.each(function(){
            var id = $(this).val();
            if(id == toBranch) { return; } // skip destination branch
            var name = branchMap[id] || $(this).text();
            var available = branchStock[id] !== undefined ? branchStock[id] : 0;
            branchOptions += '<option value="'+id+'" data-available="'+available+'">'+name+' (avail: '+available+')</option>';
        });

        $('body').modalmanager('loading');
        var modalHtml = `
              <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Fulfill Request #${reqId}</h4>
                </div>
                <div class="modal-body">
                    <form id="fulfill_form">
                        <input type="hidden" name="request_id" value="${reqId}">
                        <div class="form-group">
                            <label>To Branch</label>
                            <input type="text" class="form-control" value="${toBranchName}" readonly>
                        </div>
                        <div class="form-group">
                            <label>From Branch</label>
                        <select name="from_branch" class="form-control" required>
                                <option value="">Select</option>
                                ${branchOptions}
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Ship Quantity</label>
                            <input type="number" name="ship_qty" class="form-control" min="1" step="1" value="${requestedQty}" required>
                        </div>
                        <div class="form-group">
                            <label>Note (optional)</label>
                            <textarea name="note" class="form-control" rows="2"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-default" data-dismiss="modal">Close</button>
                    <button class="btn btn-success" id="submit_fulfill">Fulfill</button>
                </div>
            </div>
        `;
        $modal.html(modalHtml);
        $modal.modal();
    });

    $modal.on('click','#submit_fulfill', function(){
        var form = $('#fulfill_form')[0];
        if(!form.checkValidity()){
            form.reportValidity();
            return;
        }
        // client-side guard: quantity cannot exceed available in selected branch
        var selected = $('#fulfill_form select[name=\"from_branch\"] option:selected');
        var available = parseFloat(selected.data('available')) || 0;
        var qty = parseFloat($('#fulfill_form input[name=\"ship_qty\"]').val()) || 0;
        if(qty > available){
            alert('Quantity cannot exceed available stock ('+available+').');
            return;
        }

        var formData = new FormData(form);
        $('body').modalmanager('loading');
        $.ajax({
            url: _url + 'ps/request_fulfill/',
            type: 'POST',
            data: formData,
            cache: false,
            contentType: false,
            processData: false,
            dataType: 'json',
            success: function(res){
                $modal.modal('loading');
                if(res && res.status === 'success'){
                    $modal.find('.modal-body').prepend('<div class="alert alert-success">'+res.message+'</div>');
                    setTimeout(function(){ location.reload(); }, 1000);
                }else{
                    var msg = (res && res.message) ? res.message : 'Unexpected response';
                    $modal.find('.modal-body').prepend('<div class="alert alert-danger">'+msg+'</div>');
                }
            },
            error: function(){ alert('Request failed'); }
        });
    });

    // Reject
    $(document).on('click','.btn-reject', function(e){
        e.preventDefault();
        var reqId = $(this).closest('tr').data('id');
        $('body').modalmanager('loading');
        var modalHtml = `
              <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Reject Request #${reqId}</h4>
                </div>
                <div class="modal-body">
                    <form id="reject_form">
                        <input type="hidden" name="request_id" value="${reqId}">
                        <div class="form-group">
                            <label>Reason (optional)</label>
                            <textarea name="note" class="form-control" rows="3"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-default" data-dismiss="modal">Close</button>
                    <button class="btn btn-danger" id="submit_reject">Reject</button>
                </div>
              </div>
        `;
        $modal.html(modalHtml);
        $modal.modal();
    });

    $modal.on('click','#submit_reject', function(){
        var formData = new FormData($('#reject_form')[0]);
        $modal.modal('loading'); // use modal’s loader to avoid double overlay
        $.ajax({
            url: _url + 'ps/request_reject/',
            type: 'POST',
            data: formData,
            cache: false,
            contentType: false,
            processData: false,
            dataType: 'json',
            success: function(res){
                $modal.modal('loading');
                if(res && res.status === 'success'){
                    $modal.find('.modal-body').prepend('<div class="alert alert-success">'+res.message+'</div>');
                    setTimeout(function(){ location.reload(); }, 800);
                }else{
                    var msg = (res && res.message) ? res.message : 'Unexpected response';
                    $modal.find('.modal-body').prepend('<div class="alert alert-danger">'+msg+'</div>');
                }
            },
            error: function(){ alert('Request failed'); }
        });
    });
});
{/literal}
</script>
