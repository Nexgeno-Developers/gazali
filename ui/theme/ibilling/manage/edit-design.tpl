<style>
    .component-fields{
        padding-bottom:5px;
    }
    .m-b-10{
        margin-bottom:10px;
    }
</style>

<div class="modal-header">
    <button type="button" class="close" data-dismiss="modal">&times;</button>
    <h3>Edit Gift Box</h3>
</div>

<div class="modal-body">
<form class="form-horizontal" id="edit_form">

    <!-- Gift Box Name -->
    <div class="form-group">
        <label class="col-sm-2 control-label">Gift Box Name</label>
        <div class="col-sm-10">
            <input type="text" name="name" class="form-control" value="{$d.name}" required>
        </div>
    </div>

    <div class="form-group">
        <label class="col-sm-2 control-label">Branch</label>
        <div class="col-sm-10">
            <select name="branch_id" class="form-control" disabled>
                {if $user->roleid eq 0}
                    {foreach $branches as $branch}
                        <option value="{$branch.id}" {if $branch.id == $d.branch_id}selected{/if}>{$branch.alias|default:$branch.account}</option>
                    {/foreach}
                {else}
                    {foreach $branches as $branch}
                        {if $branch.id == $d.branch_id}
                            <option value="{$branch.id}" selected>{$branch.alias|default:$branch.account}</option>
                        {/if}
                    {/foreach}
                {/if}
            </select>
            {*if $user->roleid neq 0*}
                <input type="hidden" name="branch_id" value="{$d.branch_id}">
            {*/if*}
        </div>
    </div>

    <!-- Images -->
    <div class="form-group">
        <label class="col-sm-2 control-label">Gift Box Images</label>
        <div class="col-sm-7">
            <input type="file" name="design_images[]" class="form-control" accept="image/*">
        </div>
        <div class="col-sm-3">
            {$images = json_decode($d.image, true)}
            {foreach $images as $img}
                <a href="{$img}" target="_blank">
                    <img src="{$img}" width="50" height="50">
                </a>
            {/foreach}
        </div>
    </div>

    <!-- Product Type -->
    <div class="form-group hide">
        <label class="col-sm-2 control-label">Product Type</label>
        <div class="col-sm-10">
            <select name="cloth_id" class="form-control select2">
                {foreach $cloths as $cloth}
                    <option value="{$cloth.id}" {if $cloth.id == $d.cloth_id}selected{/if}>
                        {$cloth.name}
                    </option>
                {/foreach}
            </select>
        </div>
    </div>

    <!-- COMPONENTS -->
    {foreach from=$categories item=cat}
    <div class="form-group">
        <label class="col-sm-2 control-label">{$cat.name}</label>
        <div class="col-sm-10">
          {$saved = []}
          {if isset($components[$cat.value])}
              {$saved = $components[$cat.value]}
          {/if}

          <div class="component-block" data-cat="{$cat.value|escape}" data-label="{$cat.name|escape}">

              {$x = 0}

              {foreach $saved as $row}
              <div class="component-fields">
                  <div class="row">
                      <div class="col-md-5">
                          <select name="component_id[{$cat.value}][]" class="form-control select2">
                              <option value="">--Select {$cat.name}--</option>
                              {foreach from=$category_items[$cat.value] item=item}
                                  <option value="{$item.id}"
                                      {if $item.id == $row.item_id}selected{/if}>
                                      {$item.name}
                                  </option>
                              {/foreach}
                          </select>
                      </div>

                      <div class="col-md-5">
                          <input type="number"
                                name="component_qty[{$cat.value}][]"
                                class="form-control"
                                value="{$row.qty}">
                      </div>

                      <div class="col-md-2">
                          <div class="btn btn-danger btn-block"
                              onclick="removeComponent(this)">
                              <i class="fa fa-minus"></i>
                          </div>
                      </div>
                  </div>
              </div>
              {$x = $x + 1}
              {/foreach}

              <!-- ALWAYS show one empty row (ADD behavior) -->
              <div class="component-fields">
                  <div class="row">
                      <div class="col-md-5">
                          <select name="component_id[{$cat.value}][]" class="form-control select2">
                              <option value="">--Select {$cat.name}--</option>
                              {foreach from=$category_items[$cat.value] item=item}
                                  <option value="{$item.id}">{$item.name}</option>
                              {/foreach}
                          </select>
                      </div>

                      <div class="col-md-5">
                          <input type="number"
                                name="component_qty[{$cat.value}][]"
                                class="form-control"
                                placeholder="Enter Qty">
                      </div>

                      <div class="col-md-2">
                          <div class="btn btn-warning btn-block"
                              onclick="addComponent('{$cat.value}')">
                              <i class="fa fa-plus"></i>
                          </div>
                      </div>
                  </div>
              </div>
          </div>
        </div>
    </div>
    {/foreach}

    <input type="hidden" name="id" value="{$d.id}">

</form>
</div>

<div class="modal-footer">
    <button class="btn" data-dismiss="modal">Close</button>
    <button class="btn btn-primary" id="update">Update</button>
</div>

{literal}
<script>
function validateGiftBoxComponents($scope){
    var hasAtLeastOne = false;
    var message = '';

    $scope.find('.component-fields').each(function(){
        var selectedProduct = $.trim($(this).find('select').val() || '');
        var qtyRaw = $.trim($(this).find('input[name^="component_qty"]').val() || '');

        if(selectedProduct !== ''){
            var qty = parseFloat(qtyRaw);
            if(qtyRaw === '' || isNaN(qty) || qty <= 0){
                message = 'If a product is selected, enter its valid Qty.';
                return false;
            }
            hasAtLeastOne = true;
        }
    });

    if(message !== ''){
        return { valid: false, message: message };
    }

    if(!hasAtLeastOne){
        return { valid: false, message: 'Select at least one product and enter its Qty.' };
    }

    return { valid: true, message: '' };
}

function showEditValidationError(message){
    var $form = $('#edit_form');
    $form.find('.js-edit-component-error').remove();
    $form.prepend('<div class="alert alert-danger js-edit-component-error">' + message + '</div>');
}

function addComponent(cat){
    var $block = $('.component-block[data-cat="'+cat+'"]');
    var $row = $block.find('.component-fields').last().clone();

    // remove old select2 junk
    $row.find('.select2-container').remove();
    $row.find('select').removeData('select2').val('');
    $row.find('input').val('');

    $row.find('.btn-warning').parent().html(
        '<div class="btn btn-danger btn-block" onclick="removeComponent(this)">' +
        '<i class="fa fa-minus"></i></div>'
    );

    $block.append($row);

    // SAFE init
    if ($.fn.select2) {
        $row.find('.select2').select2({
            dropdownParent: $('#ajax-modal')
        });
    }
}


function removeComponent(el){
    $(el).closest('.component-fields').remove();
}

$(document).ready(function(){
    if($.fn.select2){
        $('#edit_form .select2').select2({ dropdownParent: $('#ajax-modal') });
    }

    $('#update').on('click', function(e){
        var validation = validateGiftBoxComponents($('#edit_form'));
        if(!validation.valid){
            e.preventDefault();
            e.stopImmediatePropagation();
            showEditValidationError(validation.message);
            return false;
        }
        $('#edit_form').find('.js-edit-component-error').remove();
        return true;
    });
});
</script>
{/literal}
