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
        var refundManual = false;

        function recalc(){
            var grand = calculateTotals();
            if(paidTotal > 0 && !refundManual){
                var suggested = Math.min(paidTotal, grand);
                $('#refund_amount').val(suggested.toFixed(2));
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
