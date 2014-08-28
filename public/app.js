$(".arrow-one").hide();
$(".arrow-two").hide();
$(".arrow-three").hide();
$(".arrow-four").hide();

$(".brand").hover(function(){
  $(".arrow-one").show();
  },function(){
  $(".arrow-one").hide();
});

$(".movies").hover(function(){
  $(".arrow-two").show();
  },function(){
  $(".arrow-two").hide();
});

$(".highest").hover(function(){
  $(".arrow-three").show();
  },function(){
  $(".arrow-three").hide();
});

$(".newest").hover(function(){
  $(".arrow-four").show();
  },function(){
  $(".arrow-four").hide();
});
