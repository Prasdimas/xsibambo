<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Youtube View</title>

    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css?family=Quicksand">
          <link href="https://vjs.zencdn.net/4.3/video-js.css" rel="stylesheet">
  <script src="https://vjs.zencdn.net/4.3/video.js"></script>
    
    <style>
    body {
        font-family: 'Quicksand'
    }
    .title {
        font-weight: 400;
        font-size: 18px;
    }
    .title h3 {
        margin-bottom: 3px;
    }

    .views {
        font-size: .8em
    }
    </style>

</head>
<body>

  <video id="my_video_1" class="video-js vjs-default-skin vjs-4-3" controls preload="auto" 
  data-setup='{ "asdf": true }' poster="http://video-js.zencoder.com/oceans-clip.png" >
    <source src="<?=$data->url?>" type='video/mp4'>
    <!-- <source src="https://vjs.zencdn.net/v/oceans.webm" type='video/webm'> -->
  </video>

  <hr />
<div class="title">
    <h3><?=$data->title;?></h3>
</div>
<div class="views"><?=$data->views;?> views</div>
<p><?=$data->description;?>
</body>
<script>
videojs.autoSetup();

videojs('my_video_1').ready(function(){
  console.log(this.options()); //log all of the default videojs options
  
   // Store the video object
  var myPlayer = this, id = myPlayer.id();
  // Make up an aspect ratio
  var aspectRatio = 360/640; 

  function resizeVideoJS(){
    var width = document.getElementById(id).parentElement.offsetWidth;
    myPlayer.width(width).height( width * aspectRatio );

  }
  
  // Initialize resizeVideoJS()
  resizeVideoJS();
  // Then on resize call resizeVideoJS()
  window.onresize = resizeVideoJS; 
});
</script>
</html>