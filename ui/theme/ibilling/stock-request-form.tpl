<div class="modal-header">
    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
    <h3>Request Stock: {$item.name}</h3>
</div>
<div class="modal-body">
    <form id="stock_request_form">
        <input type="hidden" name="item_id" value="{$item.id}">
        <div class="form-group">
            <label class="control-label">To Branch</label>
            <input type="text" class="form-control" value="{get_branch_name($to_branch_id, alias)}" readonly>
        </div>
        <div class="form-group">
            <label class="control-label">Quantity</label>
            <input type="number" name="qty" min="1" step="0.01" class="form-control" required>
        </div>
        <div class="form-group">
            <label class="control-label">Note (optional)</label>
            <textarea name="note" class="form-control" rows="3"></textarea>
        </div>
    </form>
</div>
<div class="modal-footer">
    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
    <button type="button" class="btn btn-primary" id="submit_stock_request">Submit Request</button>
</div>
