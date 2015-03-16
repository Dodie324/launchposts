var clickCount = 0;
var topicId = $(".topic_header").attr("name")

$(window).scroll(function(e) {
   if ($(window).scrollTop() + $(window).height() == $(document).height()) {
    e.preventDefault();
    clickCount += 1

       $.get("/posts/" + topicId + ".json?page=" + clickCount, function (newPosts) {
           newPosts.forEach(function (newPost) {
              var $postContainer = $('<div>').addClass('post callout panel')

              var $postTitle = $('<div>').addClass('post_title').text(newPost.title);

              var $postUrlContainer = $('<div>').addClass('post_url');

              var completeUrl = $postUrlContainer.append("<a href='" + newPost.url + "'>" + newPost.url + "</a>")

              var $postDesc = $('<div>').addClass('post_desc').text(newPost.description)

              $postContainer.append($postTitle);
              $postContainer.append(completeUrl);
              $postContainer.append($postDesc);
              $('.all_posts').append($postContainer);
         });
    });
  };
});
