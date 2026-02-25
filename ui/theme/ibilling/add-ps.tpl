{include file="sections/header.tpl"}
<div class="wrapper wrapper-content">
   <div class="row">
      <div class="col-lg-12">
         <div class="ibox float-e-margins">
            <div class="ibox-title">
               <h5>
                  Add Product
               </h5>
               <div class="ibox-tools">
                  <a href="{$_url}ps/p-list" class="btn btn-primary btn-xs">List Products</a>
               </div>
            </div>
            <div class="ibox-content" id="ibox_form">
               <div class="alert alert-danger" id="emsg">
                  <span id="emsgbody"></span>
               </div>
               <form class="form-horizontal" id="rform">
                  <div class="form-group margbtm_5">
                     <label class="col-lg-2 control-label" for="product_type">Product Type</label>
                     <div class="col-lg-10">
                        <!--<select name="product_type" class="form-control" onchange="get_category(this.value);">
                           <option value="readymade">Readymade</option>
                           <option value="customize">Customize</option>
                        </select>-->

                     <div class="radio-button">
                         <input type="radio" name="product_type" onchange="get_category(this.value);" value="readymade" id="readymade" checked/>
                         <label for="readymade">Readymade</label>
                     </div>


                    <div class="radio-button">
                        <input type="radio" name="product_type" onchange="get_category(this.value);" value="customize" id="customize"/> 
                        <label for="customize">Customize</label>  
                    </div>
                    
                     </div>
                  </div>

                  <div class="form-group product_category margbtm_5"></div>	
                  
        		<div class="form-group" id="vendorGroup" style="display:none;">
        			<label class="col-lg-2 control-label" for="vendor_id">Vendor</label>
        			<div class="col-lg-10">
        				<select id="vendorId" name="vendor_id" class="form-control">
        				    <option value="">--Select--</option>
        				    {foreach $vendorList as $row}
        				        <option value="{$row['id']}">{$row['account']}</option>
        				    {/foreach}
        				</select>
        			</div>
        		</div>                  
				  
                  <div class="form-group">
                     <label class="col-lg-2 control-label" for="name">{$_L['Name']}</label>
                     <div class="col-lg-10">
                        <input type="text" id="name" name="name" class="form-control" autocomplete="off">
                     </div>
                  </div>

                  <div class="form-group">
                     <label class="col-lg-2 control-label" for="purchase_price">Purchase price</label>
                     <div class="col-lg-10">
                        <input type="text" id="purchase_price" name="purchase_price" class="form-control amount" autocomplete="off" data-a-sign="{$_c['currency_code']} "
                           data-a-dec="{$_c['dec_point']}" data-a-sep="{$_c['thousands_sep']}" data-d-group="2">
                     </div>
                  </div>

                  <div class="form-group">
                     <label class="col-lg-2 control-label" for="sales_price">Sale price</label>
                     <div class="col-lg-10">
                        <input type="text" id="sales_price" name="sales_price" class="form-control amount" autocomplete="off" data-a-sign="{$_c['currency_code']} "
                           data-a-dec="{$_c['dec_point']}" data-a-sep="{$_c['thousands_sep']}" data-d-group="2">
                     </div>
                  </div>

                  <div class="form-group">
                     <label class="col-lg-2 control-label" for="sales_price">Branch</label>
                     <div class="col-lg-10">
                           <select name="branch_id" id="branch_id" class="form-control" required>
                              <option value="">Select Branch</option>
                              {foreach $branches as $branch}
                                 <option value="{$branch.id}">{$branch.alias|default:$branch.account}</option>
                              {/foreach}
                           </select>
                     </div>
                  </div>

                  <div class="form-group">
                     <label class="col-lg-2 control-label" for="product_stock">Stock</label>
                     <div class="col-lg-7">
                        <input type="number" name="product_stock" class="form-control" autocomplete="off" placeholder="e.g : 10">
                     </div>
                     <div class="col-lg-3">
                        <select name="product_stock_type" class="form-control">
                            <option value="pieces">Pieces</option>
                            <option value="gram">Gram (1 tola ≈ 12 g)</option>
                        </select>
                        <!--<input type="text" name="product_stock_type" class="form-control" autocomplete="off" placeholder="e.g : kg, meter, packet">-->
                     </div>
                     <div class="col-lg-offset-2 col-lg-10">
                        <small id="stockTolaHint" class="text-muted" style="display:none;"></small>
                     </div>					 
                  </div>
                  <div class="form-group">
                     <label class="col-lg-2 control-label" for="product_image">Product Image</label>
                     <div class="col-lg-9">
                        <input type="file" id="product_image" name="product_image" class="form-control" autocomplete="off" accept="image/*">
                     </div>
                     <div class="col-lg-1">
                         <img class="img-popup" id="ready_img" src="" width="100%" />
                         <input name="ready_img" type="hidden" value="">
                     </div>
                  </div>
                  <div class="form-group">
                     <label class="col-lg-2 control-label" for="description">{$_L['Description']}</label>
                     <div class="col-lg-10">
                        <textarea id="description" name="description" class="form-control" rows="3"></textarea>
                     </div>
                  </div>
                  <div class="form-group" style="display:none;">
                     <label class="col-lg-2 control-label" for="item_number">{$_L['Item Number']}</label>
                     <div class="col-lg-10">
                        <input type="text" id="item_number" value="{$nxt}" name="item_number" class="form-control" autocomplete="off">
                     </div>
                  </div>
                  <input type="hidden" id="type" name="type" value="Product">
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

<script>
function get_category(val)
{
	if(val == 'customize')
	{
		$('.product_category').html('<label class="col-lg-2 control-label" for="product_category">Product Category</label><div class="col-lg-10">{assign itemCategory get_item_categories()} {foreach $itemCategory as $cat}<div class="radio-button"><input type="radio" name="product_category" value="{$cat["value"]}" id="{$cat["value"]}"><label for="{$cat["value"]}">{$cat["name"]}</label></div>{/foreach}  </div>');  
        
        $('#purchase_price').val('');
        $('#sales_price').val('');
        $('#ready_img').attr('src', '');
        $('input[name="ready_img"]').val('');        
        
        $("#vendorGroup").show();
        $("#vendorId").prop("disabled", false);

	}
	else
	{
        $('.product_category').html('<label class="col-lg-2 control-label" for="design_id">Select Gift Box</label><div class="col-lg-10"> <select id="design_id" name="design_id" class="form-control"><option value="">--Select gift box--</option>{foreach get_designs() as $row}<option value="{$row["id"]}">{$row["name"]}</option>{/foreach}</select></div>');
        $('#design_id').select2();
        
        // Reset the select element to its default option (first option in this case)
        $("#vendorId").val($("#vendorId option:first").val());
        
        // Disable the select element
        $("#vendorId").prop("disabled", true);
        $("#vendorGroup").hide();        
    }

}

$(document).ready(function(){
        const gramsPerTola = 12;
        const $stockInput = $('input[name=\"product_stock\"]');
        const $unitSelect = $('select[name=\"product_stock_type\"]');
        const $tolaHint = $('#stockTolaHint');

        function renderTolaHint(){
            const unit = $unitSelect.val();
            const grams = parseFloat($stockInput.val());
            if(unit === 'gram'){
                if(!isNaN(grams)){
                    const tola = grams / gramsPerTola;
                    $tolaHint.text(grams + ' gram ≈ ' + tola.toFixed(2) + ' tola');
                }else{
                    $tolaHint.text('Enter grams to see value in tola');
                }
                $tolaHint.show();
            }else{
                $tolaHint.hide();
            }
        }

        $stockInput.on('input', renderTolaHint);
        $unitSelect.on('change', renderTolaHint);

        get_category('');
        renderTolaHint();
    });
</script>

{include file="sections/footer.tpl"}

