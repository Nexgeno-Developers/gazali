{include file="sections/header.tpl"}

<div class="wrapper wrapper-content">
    <div class="row">
        <div class="col-md-12">
            <div class="ibox float-e-margins border-radius-16px">
                <div class="ibox-title">
                    <h5>{if $mode eq 'edit'}Edit{else}Add{/if} Product Category</h5>
                </div>
                <div class="ibox-content">
                    <form class="form-horizontal" method="post" action="{$_url}ps/category-save/">
                        <input type="hidden" name="id" value="{$category.id|default:''}">

                        <div class="form-group">
                            <label class="col-lg-2 control-label" for="name">Name</label>
                            <div class="col-lg-10">
                                <input type="text" id="name" name="name" value="{$category.name|default:''}" class="form-control" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-lg-2 control-label" for="value">Value</label>
                            <div class="col-lg-10">
                                <input type="text" id="value" name="value" value="{$category.value|default:''}" class="form-control" {if $mode eq 'edit'}readonly{/if} required>
                                <span class="help-block m-b-none">Lowercase, letters/numbers/underscores only.</span>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-lg-offset-2 col-lg-10">
                                <button class="btn btn-primary" type="submit"><i class="fa fa-check"></i> Save</button>
                                <a class="btn btn-default" href="{$_url}ps/category-list/">Cancel</a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
$(function(){
    var mode = "{$mode}";
    if(mode !== 'edit'){
        $('#name').on('keyup blur', function(){
            var slug = $(this).val().toLowerCase().trim()
                .replace(/\s+/g, '_')
                .replace(/[^a-z0-9_]/g, '');
            if(slug && !$('#value').is(':focus')){
                $('#value').val(slug);
            }
        });
    }
});
</script>

{include file="sections/footer.tpl"}
