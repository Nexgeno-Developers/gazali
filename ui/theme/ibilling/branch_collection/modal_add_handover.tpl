<div class="modal-header">
    <button type="button" class="close" data-dismiss="modal">&times;</button>
    <h3>Add Handover for Collection #{$collection.id}</h3>
</div>

<div class="modal-body">
    {if !$can_add}
        <div class="alert alert-info" role="alert" style="margin-bottom:0">
            <strong>Nothing pending.</strong><br>
            Requested: <b>{$currency_prefix}{$cap_total|number_format:2:'.':''}</b>
            (Cash: {$currency_prefix}{$cap_cash|number_format:2:'.':''}, QR: {$currency_prefix}{$cap_qr|number_format:2:'.':''})<br>
            Handed over: <b>{$currency_prefix}{$paid_all|number_format:2:'.':''}</b>
            (Cash: {$currency_prefix}{$paid_cash|number_format:2:'.':''}, QR: {$currency_prefix}{$paid_qr|number_format:2:'.':''})<br>
            Remaining: <b>{$currency_prefix}{$remain_total|number_format:2:'.':''}</b>
            (Cash: {$currency_prefix}{$remain_cash|number_format:2:'.':''}, QR: {$currency_prefix}{$remain_qr|number_format:2:'.':''})
        </div>
    {else}
        <div class="well" style="padding:10px; margin-bottom:12px;">
            <div style="display:flex; gap:18px; flex-wrap:wrap; font-size:13px;">
                <div>
                    Requested: <b>{$currency_prefix}{$cap_total|number_format:2:'.':''}</b><br>
                    <small class="text-muted">(Cash: {$currency_prefix}{$cap_cash|number_format:2:'.':''} | QR: {$currency_prefix}{$cap_qr|number_format:2:'.':''})</small>
                </div>
                <div>
                    Already handed over: <b>{$currency_prefix}{$paid_all|number_format:2:'.':''}</b><br>
                    <small class="text-muted">(Cash: {$currency_prefix}{$paid_cash|number_format:2:'.':''} | QR: {$currency_prefix}{$paid_qr|number_format:2:'.':''})</small>
                </div>
                <div>
                    Remaining: <b id="remaining_total">{$currency_prefix}{$remain_total|number_format:2:'.':''}</b><br>
                    <small class="text-muted">
                        (Cash: <b id="remain_cash">{$currency_prefix}{$remain_cash|number_format:2:'.':''}</b> |
                        QR: <b id="remain_qr">{$currency_prefix}{$remain_qr|number_format:2:'.':''}</b>)
                    </small>
                </div>
            </div>
        </div>

        <form class="form-horizontal" id="ib_modal_form" action="{$smarty.server.REQUEST_URI}">
            <input type="hidden" id="cash_breakdown_json" name="cash_breakdown_json" value="">
            <div class="form-group">
                <label class="col-lg-4 control-label">Type <small class="red">*</small></label>
                <div class="col-lg-8">
                    <select name="payment_type" id="payment_type" class="form-control" required>
                        <option value="Cash" {if $remain_cash <= 0}disabled{/if}>Cash {if $remain_cash <= 0}(No balance){/if}</option>
                        <option value="QR"   {if $remain_qr   <= 0}disabled{/if}>QR {if $remain_qr   <= 0}(No balance){/if}</option>
                    </select>
                    <small class="text-muted">Choose where this handover belongs.</small>
                </div>
            </div>

            <div class="form-group" id="cash_breakup_wrap" style="display:none;">
                <label class="col-lg-4 control-label">Cash Details</label>
                <div class="col-lg-8">
                    <div class="table-responsive" style="max-height:380px; overflow-y:auto; border:1px solid #e5e5e5;">
                        <table class="table table-condensed" style="margin-bottom:4px;">
                            <thead>
                                <tr>
                                    <th style="width:35%;">Denomination</th>
                                    <th style="width:30%;">Count</th>
                                    <th style="width:35%;">Value</th>
                                </tr>
                            </thead>
                            <tbody id="cash_rows">
                                {foreach from=[500,200,100,50,10,5,1] item=denom}
                                    <tr data-denom="{$denom}">
                                        <td><span class="label label-default" style="display:inline-block; min-width:48px;">{$currency_prefix}{$denom}</span></td>
                                        <td>
                                            <input type="number"
                                                   name="cash_notes[{$denom}]"
                                                   class="form-control input-sm cash-count"
                                                   min="0"
                                                   step="1"
                                                   value="0"
                                                   data-denom="{$denom}">
                                        </td>
                                        <td class="cash-value text-right" style="padding-right:8px;">{$currency_prefix}0.00</td>
                                    </tr>
                                {/foreach}
                            </tbody>
                            <tfoot>
                                <tr>
                                    <th colspan="2" class="text-right">Total</th>
                                    <th class="text-right" id="cash_total">{$currency_prefix}0.00</th>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                    <small class="help-block" style="margin-top:4px;">Totals auto-calculate and must match <b>Amount Paid</b> for cash handovers.</small>
                </div>
            </div>

            <div class="form-group">
                <label class="col-lg-4 control-label">Amount Paid <small class="red">*</small></label>
                <div class="col-lg-8">
                    <input type="number"
                           name="amount_paid"
                           id="amount_paid"
                           class="form-control"
                           step="0.01"
                           min="0.01"
                           required
                           data-remain-cash="{$remain_cash}"
                           data-remain-qr="{$remain_qr}">
                    <small id="amount_hint" class="help-block" style="margin:4px 0 0;">
                        Max for <b id="type_label">Cash</b>:
                        <b id="type_max">{$currency_prefix}{$remain_cash|number_format:2:'.':''}</b>.
                        Balance after this entry: <b id="after_balance">{$currency_prefix}{$remain_cash|number_format:2:'.':''}</b>
                    </small>
                </div>
            </div>

            <div class="form-group">
                <label class="col-lg-4 control-label">Paid Date <small class="red">*</small></label>
                <div class="col-lg-8">
                    <input type="date" name="paid_date" class="form-control" value="{$today}" required>
                </div>
            </div>

            <div class="form-group">
                <label class="col-lg-4 control-label">Note</label>
                <div class="col-lg-8">
                    <textarea name="note" class="form-control" rows="2"></textarea>
                </div>
            </div>

            <input type="hidden" name="collection_id" value="{$collection.id}">
        </form>

        <input type="hidden" id="currency_prefix_val" value="{$currency_prefix|escape:'html'}">

        {literal}
        <script>
        (function(){
          function toN(v){ var n=parseFloat(v); return isNaN(n)?0:n; }
          function fmt(n){ return (Math.round(n*100)/100).toFixed(2); }
          var cpEl = document.getElementById('currency_prefix_val');
          var RS = cpEl ? cpEl.value : '';

          var sel  = document.getElementById('payment_type');
          var amt  = document.getElementById('amount_paid');
          var lab  = document.getElementById('type_label');
          var maxEl= document.getElementById('type_max');
          var after= document.getElementById('after_balance');
          var wrap = document.getElementById('cash_breakup_wrap');
          var cashRows = document.getElementById('cash_rows');
          var cashTotalEl = document.getElementById('cash_total');

          if(!sel || !amt) return;

          function denomTotal(){
            if(!cashRows) return 0;
            var total = 0;
            var breakdown = {};
            cashRows.querySelectorAll('.cash-count').forEach(function(inp){
              var count = toN(inp.value);
              var denom = toN(inp.getAttribute('data-denom'));
              var row   = inp.closest('tr');
              var val = count * denom;
              total += val;
              breakdown[denom] = count;
              var cell = row ? row.querySelector('.cash-value') : null;
              if(cell){ cell.textContent = RS + fmt(val); }
            });
            if(cashTotalEl){ cashTotalEl.textContent = RS + fmt(total); }
            var hidden = document.getElementById('cash_breakdown_json');
            if(hidden){ hidden.value = JSON.stringify(breakdown); }
            return total;
          }

          function currentMax(){
            var rc = toN(amt.getAttribute('data-remain-cash'));
            var rq = toN(amt.getAttribute('data-remain-qr'));
            return (sel.value === 'QR') ? rq : rc;
          }

          function updateHint(){
            var cap = currentMax();
            lab.textContent = sel.value;
            maxEl.textContent = RS + fmt(cap);

            var val = toN(amt.value);
            if (val > cap && amt.value !== '') {
              amt.value = fmt(cap);
              val = cap;
            }
            after.textContent = RS + fmt(Math.max(0, cap - val));

            if(wrap){
              wrap.style.display = (sel.value === 'Cash') ? '' : 'none';
            }
            if(sel.value === 'Cash'){
              var dt = denomTotal();
              if(dt > 0){ amt.value = fmt(dt); }
            }
          }

          sel.addEventListener('change', updateHint);
          amt.addEventListener('input', updateHint);

          if(cashRows){
            cashRows.addEventListener('input', function(e){
              if(!e.target.classList.contains('cash-count')) return;
              var total = denomTotal();
              if(sel.value === 'Cash'){
                amt.value = fmt(total);
                updateHint();
              }
            });
          }

          var form = document.getElementById('ib_modal_form');
          if(form){
            form.addEventListener('submit', function(e){
              if(sel.value !== 'Cash') return;
              var total = denomTotal();
              var paid  = toN(amt.value);
              if(Math.abs(total - paid) > 0.009){
                e.preventDefault();
                alert('Cash breakdown total (' + RS + fmt(total) + ') must equal Amount Paid (' + RS + fmt(paid) + ').');
                return false;
              }
              // serialize cash counts to JSON for backend storage (redundant safety)
              denomTotal();
            });
          }

          updateHint();
        })();
        </script>
        {/literal}
    {/if}
</div>

<div class="modal-footer">
    <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
    {if $can_add}
        <button type="submit" class="btn btn-primary modal_submit"><i class="fa fa-check"></i> Save</button>
    {/if}
</div>
