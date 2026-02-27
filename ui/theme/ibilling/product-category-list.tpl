{include file="sections/header.tpl"}

<div class="wrapper wrapper-content">
    <div class="row">
        <div class="col-md-12">
            <div class="ibox float-e-margins">
                <div class="ibox-title">
                    <h5>Product Categories</h5>
                    <div class="ibox-tools">
                        <a href="{$_url}ps/category-add/" class="btn btn-primary btn-xs">
                            <i class="fa fa-plus"></i> Add Category
                        </a>
                    </div>
                </div>
                <div class="ibox-content table-responsive">
                    {if $categories|@count gt 0}
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Name</th>
                                    <th>Value</th>
                                    <th>Created</th>
                                    <th width="180">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {foreach $categories as $cat}
                                    <tr>
                                        <td>{$cat.id}</td>
                                        <td>{$cat.name}</td>
                                        <td><code>{$cat.value}</code></td>
                                        <td>{if $cat.timestamp}{$cat.timestamp}{else}-{/if}</td>
                                        <td>
                                            <a class="btn btn-xs btn-info" href="{$_url}ps/category-edit/{$cat.id}/">
                                                <i class="fa fa-edit"></i> Edit
                                            </a>
                                            <button class="btn btn-xs btn-danger delete-category" data-id="{$cat.id}">
                                                <i class="fa fa-trash"></i> Delete
                                            </button>
                                        </td>
                                    </tr>
                                {/foreach}
                            </tbody>
                        </table>
                    {else}
                        <p>No product categories found.</p>
                    {/if}
                </div>
            </div>
        </div>
    </div>
</div>

<script>
$(function(){
    var base_url = $("#_url").val() || "{$_url}";
    $('.delete-category').on('click', function(){
        var id = $(this).data('id');
        bootbox.confirm("Delete this category? The related category will be removed only if it has no data.", function(result){
            if(result){
                window.location = base_url + 'ps/category-delete/' + id + '/';
            }
        });
    });
});
</script>

{include file="sections/footer.tpl"}
