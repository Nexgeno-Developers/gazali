{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-8">
        <div class="ibox float-e-margins">
            <div class="ibox-title">
                <h5>Return Invoice #{$cn.creditnotenum|default:$cn.id}</h5>
            </div>
            <div class="ibox-content">
                <p><strong>Customer:</strong> {$customer.account|default:'N/A'}<br>
                   <strong>Date:</strong> {$cn.date}<br>
                   {if $original_invoice}<strong>Original Invoice:</strong> {$original_invoice.invoicenum} ({$original_invoice.id})<br>{/if}
                   <strong>Status:</strong> {$cn.status}</p>

                <div class="table-responsive">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th class="text-right">Qty</th>
                                <th class="text-right">Price</th>
                                <th class="text-right">Total</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach $items as $it}
                            <tr>
                                <td>{$it.description}</td>
                                <td class="text-right">{$it.qty}</td>
                                <td class="text-right"><span class="amount">{$it.amount}</span></td>
                                <td class="text-right"><span class="amount">{$it.total}</span></td>
                            </tr>
                            {/foreach}
                        </tbody>
                    </table>
                </div>

                <table class="table">
                    <tr>
                        <th class="text-right" style="width:70%">Subtotal</th>
                        <td class="text-right"><span class="amount">{$cn.subtotal}</span></td>
                    </tr>
                    <tr>
                        <th class="text-right">Total</th>
                        <td class="text-right"><strong class="amount">{$cn.total}</strong></td>
                    </tr>
                </table>

                {if $cn.notes}
                    <p><strong>Notes:</strong><br>{$cn.notes|escape}</p>
                {/if}
            </div>
        </div>
    </div>
</div>

{include file="sections/footer.tpl"}
