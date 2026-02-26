<div class="modal-header">
	<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
	<h3>Edit</h3>
</div>
<div class="modal-body">
	<form class="form-horizontal" role="form" id="edit_form" method="post">
		<div class="form-group">
			<label class="col-lg-2 control-label" for="product_type">Product Type</label>
			<div class="col-lg-10">
				<input name="product_type" class="form-control" type="text" value="{$d['product_type']}" readonly>
			</div>
		</div>
		{if $d['product_type'] eq 'customize'}
		<div class="form-group">
			<label class="col-lg-2 control-label" for="product_category">Product Category</label>
			<div class="col-lg-10">
				{assign itemCategory  get_item_categories()}
				{foreach $itemCategory as $cat}
				<div class="radio-button">
					<input type="radio" name="product_category" value="{$cat['value']}" id="{$cat['value']}" {if $d[ 'product_category'] eq $cat['value']} checked {/if}/> 
					<label for="{$cat['value']}">{$cat['name']}</label> 
				</div>				
				{/foreach}
			</div>
		</div>
		{else}
		<div class="form-group">
			<label for="name" class="col-sm-2 control-label">Gift Box</label>
			<div class="col-sm-10">
				<input type="text" class="form-control" value="{get_type_by_id('sys_designs', 'id', $d['design_id'], 'name')}" readonly>
			</div>
		</div>		
		{/if}
		<div class="form-group">
			<label for="name" class="col-sm-2 control-label">{$_L['Name']}</label>
			<div class="col-sm-10">
				<input type="text" class="form-control" value="{$d['name']}" name="name" id="name">
			</div>
		</div>
		<div class="form-group" style="display:none;">
			<label for="rate" class="col-sm-2 control-label">{$_L['Item Number']}</label>
			<div class="col-sm-10">
				<input type="text" class="form-control" name="item_number" value="{$d['item_number']}" id="item_number">
				<input type="hidden" name="id" value="{$d['id']}">
			</div>
		</div>
		<div class="form-group">
			<label class="col-lg-2 control-label" for="purchase_price">Purchase price</label>
			<div class="col-lg-10">
				<input type="text" id="purchase_price" name="purchase_price" value="{$d['purchase_price']}" class="form-control" autocomplete="off">
			</div>
		</div>
		<div class="form-group">
			<label for="rate" class="col-sm-2 control-label">Sale Price</label>
			<div class="col-sm-10">
				<input type="text" class="form-control" name="sales_price" value="{$d['sales_price']}" id="price">

			</div>
		</div>
		<div class="form-group">
			<label class="col-lg-2 control-label" for="product_stock">Stock</label>
			<div class="col-lg-7">
				<input type="text" name="product_stock" class="form-control" value="{$d['product_stock']}" autocomplete="off" placeholder="e.g : 10" readonly>
			</div>
			<div class="col-lg-3">
					<select name="product_stock_type" class="form-control">
						<option value="kg" {if $d['product_stock_type'] eq 'kg'} selected {/if}>KG</option>
						<option value="tola" {if $d['product_stock_type'] eq 'tola'} selected {/if}>Tola (1 tola ≈ 12 g)</option>
						<option value="gram" {if $d['product_stock_type'] eq 'gram'} selected {/if}>Gram</option>
						<option value="pieces" {if $d['product_stock_type'] eq 'pieces'} selected {/if}>Pieces</option>
					</select>				
				<!--<input type="text" name="product_stock_type" value="{$d['product_stock_type']}" class="form-control" autocomplete="off" placeholder="e.g : kg, meter, packet">-->
			</div>
			<div class="col-lg-offset-2 col-lg-10">
				<small id="editStockTolaHint" class="text-muted" style="display:none;"></small>
			</div>
		</div>
		<div class="form-group">
			<label class="col-lg-2 control-label" for="product_image">Product Image</label>
			<div class="col-lg-9">
				<input type="file" id="product_image" name="product_image" class="form-control" autocomplete="off" accept="image/*">
			</div>
			<div class="col-lg-1"><img width="100%" src="{$d['product_image']}"></div>
		</div>
		<div class="form-group">
			<label for="name" class="col-sm-2 control-label">{$_L['Description']}</label>
			<div class="col-sm-10">
				<textarea id="description" name="description" class="form-control" rows="3">{$d['description']}</textarea>
			</div>
		</div>
		<input type="hidden" name="id" value="{$d['id']}">
	</form>
</div>
<div class="modal-footer">
	<button type="button" data-dismiss="modal" class="btn">{$_L['Close']}</button>
	<button id="update" class="btn btn-primary">{$_L['Update']}</button>
</div>
{literal}
<script>
(function(){
	const gramsPerTola = 12;
	const $form = $('#edit_form');
	const $stock = $form.find('input[name="product_stock"]');
	const $unit = $form.find('select[name="product_stock_type"]');
	const $hint = $('#editStockTolaHint');

	function renderHint(){
		const unit = $unit.val();
		const grams = parseFloat($stock.val());
		if(unit === 'gram'){
			if(!isNaN(grams)){
				const tola = grams / gramsPerTola;
				$hint.text(grams + ' gram ≈ ' + tola.toFixed(2) + ' tola');
			}else{
				$hint.text('Enter grams to see value in tola');
			}
			$hint.show();
		}else{
			$hint.hide();
		}
	}

	$unit.on('change', renderHint);
	$stock.on('input', renderHint);
	renderHint();
})();
</script>
{/literal}
