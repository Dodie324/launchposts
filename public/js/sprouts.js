// YOUR CODE GOES HERE
var clickCount = 1
var $sprouts = $(".more-sprouts")

$sprouts.hide();

$(document).ready(function() {
  $sprouts.on("click", function (event) {
    event.preventDefault();
    clickCount += 1

      $.get("/tweets.json?page=" + clickCount, function (newTweets) {
        newTweets.forEach(function (newTweet) {
          var $li = $('<li>').addClass('tweet');
          var $text = $('<div>').addClass('body').html(newTweet.text);
          $(".tweets").append($li.html($text.text() + newTweet.username));
        // $(".tweets").append("<li class='tweet'><div class='body'>" + newTweet.text + "</div><div class='user'>" + newTweet.username + "</div></li>");
      });
    });
  });
});

////////////////////////////////////////////

$(window).scroll(function() {
   if ($(window).scrollTop() + $(window).height() == $(document).height()) {
      clickCount += 1

       $.get("/tweets.json?page=" + clickCount, function (newTweets) {
         newTweets.forEach(function (newTweet) {
           var $li = $('<li>').addClass('tweet');
           var $text = $('<div>').addClass('body').html(newTweet.text);
           $(".tweets").append($li.html($text.text() + newTweet.username));
        //  $(".tweets").append("<li class='tweet'><div class='body'>" + newTweet.text + "</div><div class='user'>" + newTweet.username + "</div></li>");
       });
    });
  };
});
