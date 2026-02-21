{include file="sections/header.tpl"}

<form method="post" action="{$_url}creditnotes/save/" id="creditnote-form">
<div class="row">
    <div class="col-md-12">
        <div class="ibox float-e-margins">
            <div class="ibox-title">
                <h5>Create Return Invoice</h5>
                <div class="ibox-tools">
                    <button type="submit" class="btn btn-primary btn-xs" id="btnSubmit"><i class="fa fa-save"></i> Save</button>
                </div>
            </div>
            <div class="ibox-content">
                <div class="row">
                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Invoice</label>
                            <input type="text" class="form-control" value="{$invoice.invoicenum} (ID: {$invoice.id})" readonly>
                            <input type="hidden" name="original_invoice_id" value="{$invoice.id}">
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Customer</label>
                            <input type="text" class="form-control" value="{$customer.account}" readonly>
                            <input type="hidden" name="customer_id" value="{$customer.id}">
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="form-group">
                            <label for="creditnote_date">Date</label>
                            <input type="text" class="form-control" id="creditnote_date" name="creditnote_date" value="{$idate}" required>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-3">
                        <div class="form-group">
                            <label for="currency">Currency</label>
                            <input type="text" class="form-control" value="{$invoice.currency_symbol|default:$_c['currency_code']}" readonly>
                            <input type="hidden" name="currency" value="{$invoice.currency}">
                        </div>
                    </div>
                    <div class="col-md-9">
                        <div class="form-group">
                            <label for="notes">Notes</label>
                            <textarea class="form-control" id="notes" name="notes" rows="2"></textarea>
                        </div>
                    </div>
                </div>

                <h5>Return Lines (from Invoice)</h5>
                <div class="table-responsive">
                    <table class="table table-bordered" id="items-table" data-paid-total="{$paid_total}">
                        <thead>
                            <tr>
                                <th style="width:25%">Product</th>
                                <th style="width:12%">Qty to return</th>
                                <th style="width:12%">Unit</th>
                                <th style="width:12%">Price</th>
                                <th style="width:12%">Line Total</th>
                                <th style="width:10%">Available</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach $invoice_items as $it}
                                {assign var=returned value=$returned_map[$it.product_id]|default:0}
                                {assign var=available value=$it.qty-$returned}
                                {if $available > 0}
                                <tr class="item-row">
                                    <td>
                                        {$it.description}
                                        <input type="hidden" name="item_product[]" value="{$it.product_id}">
                                        <input type="hidden" name="invoice_item_id[]" value="{$it.id}">
                                        <input type="hidden" name="item_description[]" value="{$it.description}">
                                    </td>
                                    <td>
                                        <input type="number" min="0" step="1" class="form-control item_qty" name="item_qty[]" value="{$available}" max="{$available}">
                                    </td>
                                    <td>
                                        <input type="text" class="form-control" value="{$it.unit|default:'qty'}" readonly>
                                        <input type="hidden" name="item_unit[]" value="{$it.unit|default:'qty'}">
                                        <input type="hidden" class="item_branch" name="item_branch[]" value="{$it.branch_id|default:$invoice.company_id}">
                                    </td>
                                    <td>
                                        <input type="text" class="form-control item_price" name="item_price[]" value="{$it.amount}">
                                    </td>
                                    <td><input type="text" class="form-control item_total" name="item_total[]" value="0.00" readonly></td>
                                    <td><span class="label label-info">{$available}</span></td>
                                </tr>
                                {/if}
                            {/foreach}
                        </tbody>
                    </table>
                </div>
                <p class="text-muted">Quantities cannot exceed the available returnable quantity shown.</p>

                <hr>
                <div class="row">
                    <div class="col-md-4">
                        <h5>Refund (optional)</h5>
                        <div class="form-group">
                            <label for="refund_amount">Refund Amount</label>
                            <input type="number" step="0.01" class="form-control" id="refund_amount" name="refund_amount" value="0">
                        </div>
                        <div class="form-group">
                            <label for="refund_account_id">Refund From Account</label>
                            <select class="form-control" id="refund_account_id" name="refund_account_id" disabled>
                                <option value="{$invoice.company_id}">{$refund_account_name}</option>
                            </select>
                            <input type="hidden" name="refund_account_id" value="{$invoice.company_id}">
                        </div>
                        <div class="form-group">
                            <label for="refund_method">Method</label>
                            <select class="form-control" id="refund_method" name="refund_method">
                                <option value="Cash">Cash</option>
                                <option value="Online">Online</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="refund_ref">Reference</label>
                            <input type="text" class="form-control" id="refund_ref" name="refund_ref">
                        </div>
                        <div class="form-group">
                            <label for="refund_date">Refund Date</label>
                            <input type="text" class="form-control" id="refund_date" name="refund_date" value="{$idate}">
                        </div>
                    </div>
                    <div class="col-md-4 col-md-offset-4">
                        <table class="table">
                            <tr>
                                <th class="text-right">Subtotal</th>
                                <td class="text-right"><span id="summary_subtotal">0.00</span></td>
                            </tr>
                            <tr>
                                <th class="text-right">Total</th>
                                <td class="text-right"><strong id="summary_total">0.00</strong></td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
</div>
</div>
</form>

{literal}
<script>
// Fallback inline calculator in case external script is cached/blocked
(function($){
    function recalc(){
        var subtotal = 0;
        $('#items-table tbody tr').each(function(){
            var $tr = $(this);
            var qty   = parseFloat($tr.find('.item_qty').val()) || 0;
            var price = parseFloat($tr.find('.item_price').val()) || 0;
            var lineSub = qty * price;
            subtotal += lineSub;
            $tr.find('.item_total').val(lineSub.toFixed(2));
        });
        $('#summary_subtotal').text(subtotal.toFixed(2));
        $('#summary_total').text(subtotal.toFixed(2));
    }
    $(function(){
        $('#items-table').on('input change keyup', '.item_qty, .item_price', recalc);
        recalc();
    });
})(jQuery);
</script>
{/literal}

{include file="sections/footer.tpl"}
