{include file="sections/header.tpl"}
<div class="wrapper wrapper-content">
    <div class="row">
    
        <div class="col-md-12">
    
            <div class="ibox float-e-margins border-radius-16px">
                <div class="ibox-title">
                    <h5>Add Category</h5>
                </div>
                <div class="ibox-content" id="ibox_form">
    
                    <form class="form-horizontal" id="addcategoryemployee-form" method="post">
                        <input type="hidden" id="_url" name="_url" value="{$_url}">
    <div class="toaster" id="toaster" style="display: none; position: relative; margin: 10px 0;
                background-color: #51A351; color: #fff; padding: 10px;"></div>
                        <div class="row">
                            <div class="col-md-6 col-sm-12">
                                <div class="form-group"><label class="col-md-4 control-label" for="name">Category Name<small class="red">*</small> </label>
                        
                                    <div class="col-lg-8"><input required type="text" id="name" name="name" class="form-control" autofocus>
                        
                                    </div>
                                </div>
                        
                                <div class="form-group hide"><label class="col-md-4 control-label" for="price">Price</label>
                        
                                    <div class="col-lg-8"><input type="number" id="price" name="price" class="form-control">
                        
                                    </div>
                                </div>
                        
                                <div class="form-group">
                                    <label class="col-md-4 control-label" for="status">Status</label>
                                    <div class="col-lg-8">
                                        <label class="radio-inline">
                                            <input type="radio" name="status" value="1" checked> Active
                                        </label>
                                        <label class="radio-inline">
                                            <input type="radio" name="status" value="0"> Inactive
                                        </label>
                                    </div>
                                </div>

                        </div>
                        
                        
                        <div class="row">
                            <div class="col-md-12">
                                <div class="form-group">
                                    <div class="col-md-offset-2 col-lg-10">
                        
                                        <button class="md-btn md-btn-primary waves-effect waves-light addcategoryemployee-post" type="submit"><i class="fa fa-check"></i> Save</button> 
                        
                        
                                    </div>
                                </div>
                            </div>
                        </div>
                        </div>
                    </form>
            </div>
        </div>
    </div>
    
    
    </div>
</div>

<script>
var URL = $("#_url").val() || (window.location.origin + '/');

$(document).on('click', '.addcategoryemployee-post', function(e) {
    e.preventDefault();
    
    var $form = $("#addcategoryemployee-form");
    var $requiredFields = $form.find('[required]');
    var emptyFields = $requiredFields.filter(function() {
        return $(this).val().trim() === '';
    });
    
    if (emptyFields.length > 0) {
        alert("Please fill in all the required fields.");
        emptyFields.first().focus();
        return;
    }
    
    var formData = $form.serialize();
    
    $.ajax({
        url: URL + 'contacts/addcategoryemployee-post/',
        type: 'POST',
        data: formData,
        dataType: 'json',
        success: function(response) {
            var message = response.message || "Category added successfully.";
            if (response.status === 'success') {
                $("#toaster").html(message).css('background-color', '#51A351').fadeIn().delay(3000).fadeOut();
                $form[0].reset();
                location.reload();
            } else {
                $("#toaster").html(message).css('background-color', '#C9302C').fadeIn().delay(3000).fadeOut();
            }
        },
        error: function(xhr) {
            var message = "Error occurred. Please try again.";
            if (xhr.responseJSON && xhr.responseJSON.message) {
                message = xhr.responseJSON.message;
            }
            $("#toaster").html(message).css('background-color', '#C9302C').fadeIn().delay(3000).fadeOut();
        }
    });
});

</script>


{include file="sections/footer.tpl"}
