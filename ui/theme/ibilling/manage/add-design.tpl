{include file="sections/header.tpl"}
<style>
    .component-fields{
        padding-bottom:5px;
    }
    .m-b-10{
        margin-bottom:10px;
    }
</style>
<div class="wrapper wrapper-content">
  <div class="row">
    <div class="col-lg-12">
      <div class="ibox float-e-margins">
        <div class="ibox-title">
          <h5>Add Gift Box</h5>
          <div class="ibox-tools">
            <a href="{$_url}manage/list-design" class="btn btn-primary btn-xs">List Gift Boxes</a>
          </div>
        </div>
        <div class="ibox-content" id="ibox_form">
            <div class="alert alert-danger" id="emsg">
                <span id="emsgbody"></span>
            </div>
          <form class="form-horizontal" id="rform">
            <div class="form-group">
              <label class="col-lg-2 control-label" for="name">Gift Box Name</label>
              <div class="col-lg-10"><input type="text" id="name" name="name" class="form-control" autocomplete="off"></div>
            </div>
            <div class="form-group">
              <label class="col-lg-2 control-label" for="branch_id">Branch</label>
              <div class="col-lg-10">
                <select name="branch_id" id="branch_id" class="form-control select2">
                  {if $user->roleid eq 0}
                    <option value="">Select Branch</option>
                    {foreach $branches as $branch}
                      <option value="{$branch.id}" {if $default_branch_id eq $branch.id}selected{/if}>{$branch.alias|default:$branch.account}</option>
                    {/foreach}
                  {else}
                    {foreach $branches as $branch}
                      {if $branch.id eq $default_branch_id}
                        <option value="{$branch.id}" selected>{$branch.alias|default:$branch.account}</option>
                      {/if}
                    {/foreach}
                  {/if}
                </select>
                {if $user->roleid neq 0}
                  <input type="hidden" name="branch_id" value="{$default_branch_id}">
                {/if}
              </div>
            </div>
            <div class="form-group">
              <label class="col-lg-2 control-label" for="design_images">Gift Box Images</label>
              <div class="col-lg-10"><input type="file" id="design_images" name="design_images[]" class="form-control" autocomplete="off" accept="image/*"></div>
            </div>
            <div class="form-group hide">
              <label class="col-lg-2 control-label" for="description">{$_L['Description']}</label>
              <div class="col-lg-10"><textarea id="description" name="description" class="form-control" rows="3"></textarea></div>
            </div>
            <div class="form-group hide">
              <label class="col-lg-2 control-label" for="description">Product Type</label>
              <div class="col-lg-10">
                <select name="cloth_id" class="form-control select2">
                  {foreach $cloths as $cloth}<option value="{$cloth['id']}">{$cloth['name']}</option>{/foreach}
                </select>
              </div>
            </div>

            {foreach from=$categories item=cat name=catloop}
            <div class="form-group">
              <label class="col-lg-2 control-label">{$cat.name}</label>
              <div class="col-lg-10">
                <div class="component-block" data-cat="{$cat.value|escape}" data-label="{$cat.name|escape}">
                  <div class="component-fields">
                    <div class="row">
                      <div class="col-md-5">
                        <select name="component_id[{$cat.value}][]" class="form-control select2">
                          <option value="">--Select {$cat.name}--</option>
                          {if isset($category_items[$cat.value])}
                            {foreach from=$category_items[$cat.value] item=item}
                              <option value="{$item.id}">{$item.name}</option>
                            {/foreach}
                          {/if}
                        </select>
                      </div>
                      <div class="col-md-5"><input type="number" class="form-control" name="component_qty[{$cat.value}][]" placeholder="Enter Qty"></div>
                      <div class="col-md-2 change"><div class="btn btn-block btn-warning bg_greens" onclick="addComponent('{$cat.value|escape}');"><i class="fa fa-plus" aria-hidden="true"></i></div></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            {/foreach}

            <div class="form-group">
              <div class="col-lg-offset-2 col-lg-10">
                <button class="btn btn-sm btn-primary" type="submit" id="submit">{$_L['Submit']}</button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>
{include file="sections/footer.tpl"}
{literal}
<script>
function escapeHtml(str){
  return $('<div/>').text(str || '').html();
}

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

$(document).ready(function () {
    $(".progress").hide();
    $("#emsg").hide();
    $('.select2').select2();

    $("#submit").click(function (event) {
        event.preventDefault(); 
        var validation = validateGiftBoxComponents($('#rform'));
        if(!validation.valid){
            $("#emsgbody").html(validation.message);
            $("#emsg").show("slow");
            return false;
        }
        $("#emsg").hide();

        $('#ibox_form').block({ message: null });
        var formData = new FormData($('#rform')[0]);
        var _url = $("#_url").val();
        $.ajax({
            url: _url + 'manage/add-post/',
            type: 'POST',
            data: formData,
            async: false,
            cache: false,
            contentType: false,
            processData: false,
            success: function (data) {
                    setTimeout(function () {
                    var sbutton = $("#submit");
                    var _url = $("#_url").val();
                    if ($.isNumeric(data)) {
                        location.reload();
                    }
                    else {
                        $('#ibox_form').unblock();
                        $("#emsgbody").html(data);
                        $("#emsg").show("slow");
                    }
                    }, 2000);
            },
            error: function () {
                    alert("error in ajax form submission");
            }
        });
        //return false;
    });
});
    
function addComponent(cat){
  var $block = $('.component-block[data-cat="'+cat+'"]');
  var $tmpl = $block.find('.component-fields').last().clone(true, false);
  
  // Remove select2 container from cloned element
  $tmpl.find('.select2-container').remove();
  
  // Reset form values and remove select2 data
  $tmpl.find('select').each(function(){
    $(this).removeData('select2');
    $(this).val('').trigger('change');
  });
  
  $tmpl.find('input').val('');
  $tmpl.find('.btn-warning').parent().html('<div class="btn btn-block btn-danger" onclick="removeComponent(this);"><i class="fa fa-minus" aria-hidden="true"></i></div>');
  
  $block.append($tmpl);
  
  // Initialize select2 on the new cloned select elements
  $tmpl.find('select').select2();
}

function removeComponent(el){
  var $fields = $(el).closest('.component-fields');
  // Destroy select2 only if it exists
  $fields.find('select').each(function(){
    if($(this).data('select2')){
      $(this).select2('destroy');
    }
  });
  $fields.remove();
}

</script>
{/literal}
