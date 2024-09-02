<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Youtube View</title>

    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css?family=Quicksand">
    <style>

    .videoWrapper {
    position: relative;
    padding-bottom: 56.25%; /* 16:9 */
    padding-top: 25px;
    height: 0;
    }
    .videoWrapper iframe {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
    }
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
<div class="videoWrapper">
    <!-- Copy & Pasted from YouTube -->
    <iframe width="560" height="349" src="http://www.youtube.com/embed/<?=$video_id;?>?rel=0&hd=1" frameborder="0" allowfullscreen></iframe>
    
</div>
<hr />
<div class="title">
    <h3><?=$data->title;?></h3>
</div>
<div class="views"><?=$data->views;?> views</div>
<p><?=$data->description;?>
</body>
</html>