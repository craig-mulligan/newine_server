$(function(){
	var id = window.location.pathname.split("/")[3];
	$('.loading-header').hide();


	$('.apply-calibration').click(function(){
		$('.loading-header').show();
		$.ajax({
			type: "POST",
			url: '/dispensers/calibrate/' + id + '.json',
			accept: 'json',
			dataType: 'json',
			data: $('.calibrate-form').serialize(),
			success: function(data){
				console.log('changed calibration');
				$('.loading-header').hide();
				console.log(data);
				
			},
			error: function(){
				alert("Error!");
			}
		});
		
	});

});