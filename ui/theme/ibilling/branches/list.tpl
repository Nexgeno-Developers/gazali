{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-12">
        <div class="ibox float-e-margins">
            <div class="ibox-title">
                <h5>Branches</h5>
                <div class="ibox-tools">
                    <form class="form-inline" method="get" action="{$_url}branches/list/">
                        <div class="input-group">
                            <input type="text" name="q" class="form-control input-sm" placeholder="Search by name, alias or email" value="{$search}">
                            <span class="input-group-btn">
                                <button class="btn btn-sm btn-primary" type="submit"><i class="fa fa-search"></i></button>
                            </span>
                        </div>
                    </form>
                </div>
            </div>
            <div class="ibox-content">
                <div class="m-b-sm">
                    <a href="{$_url}branches/add/" class="btn btn-primary"><i class="fa fa-plus"></i> Add Branch</a>
                </div>

                <div class="table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Alias</th>
                                <th>Description</th>
                                <th>Contact</th>
                                <th>Email</th>
                                <th>Status</th>
                                <th class="text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {if $branches|@count gt 0}
                                {foreach $branches as $branch}
                                    <tr>
                                        <td>{$branch.account}</td>
                                        <td>{$branch.alias|default:'-'}</td>
                                        <td>{$branch.description|default:'-'}</td>
                                        <td>
                                            {if $branch.contact_person}{$branch.contact_person}{else}-{/if}
                                            {if $branch.contact_phone}<br><small>{$branch.contact_phone}</small>{/if}
                                        </td>
                                        <td>{if $branch.email}{$branch.email}{else}-{/if}</td>
                                        <td>{if $branch.status}{$branch.status}{else}-{/if}</td>
                                        <td class="text-right">
                                            <a href="{$_url}branches/edit/{$branch.id}/" class="btn btn-xs btn-primary">
                                                <i class="fa fa-pencil"></i> Edit
                                            </a>
                                            <a href="{$_url}branches/delete/{$branch.id}/" class="btn btn-xs btn-danger confirm-delete">
                                                <i class="fa fa-trash"></i> Delete
                                            </a>
                                        </td>
                                    </tr>
                                {/foreach}
                            {else}
                                <tr>
                                    <td colspan="7" class="text-center text-muted">No branches found.</td>
                                </tr>
                            {/if}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<input type="hidden" id="_lan_are_you_sure" value="{$_L['are_you_sure']}">

{include file="sections/footer.tpl"}
