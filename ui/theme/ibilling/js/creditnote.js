(function($){
    function calculateTotals(){
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
        return subtotal;
    }

    function bindRow($tr, recalc){
        $tr.find('.item_qty, .item_price').on('input keyup change', function(){
            var max = parseFloat($(this).attr('max'));
            var val = parseFloat($(this).val()) || 0;
            if(!isNaN(max) && val > max){
                $(this).val(max);
            }
            recalc();
        });
    }

    function initCreditNoteCalc(){
        var paidTotal = parseFloat($('#items-table').data('paid-total')) || 0;
        var availableRefund = parseFloat($('#refund_amount').data('available-refund')) || 0;
        var remainingInvoice = parseFloat($('#items-table').data('remaining-invoice')) || 0;
        var refundManual = false;

        function recalc(){
            var grand = calculateTotals();
            var maxRefund = Math.min(availableRefund, grand);
            if(isNaN(maxRefund) || maxRefund < 0){ maxRefund = 0; }
            var $refund = $('#refund_amount');
            $refund.attr('max', maxRefund.toFixed(2));
            var current = parseFloat($refund.val()) || 0;
            if(current > maxRefund){
                current = maxRefund;
                $refund.val(current.toFixed(2));
            }
            if(!refundManual){
                $refund.val(maxRefund.toFixed(2));
            }

            var $warn = $('#over_amount_warn');
            var $btn = $('#btnSubmit');
            var overBy = grand - remainingInvoice;
            if(overBy > 0.0001){
                $warn.text('Over remaining invoice amount by ' + overBy.toFixed(2));
                $warn.show();
                $btn.prop('disabled', true);
            } else {
                $warn.hide();
                $btn.prop('disabled', false);
            }
        }

        $('#items-table tbody tr').each(function(){ bindRow($(this), recalc); });
        $('#refund_amount').on('input keyup change', function(){ refundManual = true; });

        // run once after DOM ready and after all bindings
        recalc();
    }

    // Run when DOM ready
    $(document).ready(initCreditNoteCalc);
})(jQuery);
