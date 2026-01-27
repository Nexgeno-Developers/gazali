{assign var="is_edit" value=($branch && $branch->id)}
{include file="sections/header.tpl"}

<div class="row">
    <div class="col-md-12">
        <div class="ibox float-e-margins">
            <div class="ibox-title">
                <h5>{if $is_edit}Edit Branch{else}Add Branch{/if}</h5>
            </div>
            <div class="ibox-content">
                <form method="post" enctype="multipart/form-data" action="{$_url}{if $is_edit}branches/edit-post/{else}branches/add-post/{/if}">
                    {if $is_edit}
                        <input type="hidden" name="id" value="{$branch->id}">
                    {/if}

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="account">Branch Name *</label>
                                <input type="text" class="form-control" id="account" name="account" value="{$branch->account|default:''}" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="alias">Alias</label>
                                <input type="text" class="form-control" id="alias" name="alias" value="{$branch->alias|default:''}">
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <label for="address">Address</label>
                                <textarea class="form-control" id="address" name="address" rows="2">{$branch->address|default:''}</textarea>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="contact_phone">Contact Phone</label>
                                <input type="text" class="form-control" id="contact_phone" name="contact_phone" value="{$branch->contact_phone|default:''}">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="email">Email</label>
                                <input type="email" class="form-control" id="email" name="email" value="{$branch->email|default:''}">
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="company_logo">Company Logo</label>
                                <input type="file" class="form-control" id="company_logo" name="company_logo" accept="image/x-png,image/gif,image/jpeg">
                                {if $is_edit && $branch->company_logo}
                                    <small class="text-muted">
                                        Current: <a href="{$app_url}application/storage/system/{$branch->company_logo}" target="_blank">{$branch->company_logo}</a>
                                    </small>
                                {/if}
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="company_stamp">Company Stamp</label>
                                <input type="file" class="form-control" id="company_stamp" name="company_stamp" accept="image/x-png,image/gif,image/jpeg">
                                {if $is_edit && $branch->company_stamp}
                                    <small class="text-muted">
                                        Current: <a href="{$app_url}application/storage/system/{$branch->company_stamp}" target="_blank">{$branch->company_stamp}</a>
                                    </small>
                                {/if}
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="gstin">Tax Number</label>
                                <input type="text" class="form-control" id="gstin" name="gstin" value="{$branch->gstin|default:''}">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="pan">PAN</label>
                                <input type="text" class="form-control" id="pan" name="pan" value="{$branch->pan|default:''}">
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="account_number">Account Number</label>
                                <input type="text" class="form-control" id="account_number" name="account_number" value="{$branch->account_number|default:''}">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="ifsc">IFSC</label>
                                <input type="text" class="form-control" id="ifsc" name="ifsc" value="{$branch->ifsc|default:''}">
                            </div>
                        </div>
                    </div>

                    {* Hidden / optional fields kept together *}
                    <div class="row">
                        <div class="col-md-6 hide">
                            <div class="form-group">
                                <label for="description">Description</label>
                                <textarea class="form-control" id="description" name="description" rows="2">{$branch->description|default:''}</textarea>
                            </div>
                        </div>
                        <div class="col-md-6 hide">
                            <div class="form-group">
                                <label for="contact_person">Contact Person</label>
                                <input type="text" class="form-control" id="contact_person" name="contact_person" value="{$branch->contact_person|default:''}">
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-4 hide">
                            <div class="form-group">
                                <label for="status">Status</label>
                                <select class="form-control" id="status" name="status">
                                    {assign var="current_status" value=$branch->status|default:'Active'}
                                    <option value="Active" {if $current_status eq 'Active'}selected{/if}>Active</option>
                                    <option value="Inactive" {if $current_status eq 'Inactive'}selected{/if}>Inactive</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-4 hide">
                            <div class="form-group">
                                <label for="bank_name">Bank Name</label>
                                <input type="text" class="form-control" id="bank_name" name="bank_name" value="{$branch->bank_name|default:''}">
                            </div>
                        </div>
                        <div class="col-md-4 hide">
                            <div class="form-group">
                                <label for="account_type">Account Type</label>
                                <input type="text" class="form-control" id="account_type" name="account_type" value="{$branch->account_type|default:''}">
                            </div>
                        </div>
                    </div>

                    <div class="text-right">
                        <a href="{$_url}branches/list/" class="btn btn-default">Cancel</a>
                        <button type="submit" class="btn btn-primary"><i class="fa fa-check"></i> Save</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

{include file="sections/footer.tpl"}
