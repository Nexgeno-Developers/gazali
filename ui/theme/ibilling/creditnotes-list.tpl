{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-12">
        <div class="ibox float-e-margins">
            <div class="ibox-title">
                <h5>Return Invoice</h5>
                <div class="ibox-tools">
                    <a href="{$_url}creditnotes/add/" class="btn btn-primary btn-xs"><i class="fa fa-plus"></i> Add Return Invoice</a>
                </div>
            </div>
            <div class="ibox-content">
                <table class="table table-bordered table-hover footable">
                    <thead>
                        <tr>
                            <th data-sort-ignore="true">#</th>
                            <th>Customer</th>
                            <th>Date</th>
                            <th class="text-right">Total</th>
                            <th>Status</th>
                            <th data-sort-ignore="true" class="text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    {foreach $d as $cn}
                        <tr>
                            <td>{$cn.id}</td>
                            <td>{$cn.account}</td>
                            <td>{$cn.date}</td>
                            <td class="text-right"><span class="amount">{$cn.total}</span></td>
                            <td>{$cn.status|default:'Open'}</td>
                            <td class="text-right">
                                <a class="btn btn-info btn-xs" href="{$_url}creditnotes/view/{$cn.id}/"><i class="fa fa-eye"></i> View</a>
                            </td>
                        </tr>
                    {/foreach}
                    </tbody>
                </table>

                {if $paginator}
                    {$paginator['contents']}
                {/if}
            </div>
        </div>
    </div>
</div>

{include file="sections/footer.tpl"}
