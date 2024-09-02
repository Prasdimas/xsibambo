<html>
    <head>
    <style>
    body {
        text-align: center;
        margin: auto;
    }

    .container {
        width: 60%;
        margin: auto;
        border-left: 1px #333 solid;
        border-right: 1px #333 solid;
    }

    dl dt {
        float: left;
        width: 40%;
        text-align: right;
        padding-right: 15px;
    }

    dl dd {
        text-align: left;
    }

    .mt-10 { margin-top: 10px; }
    .mt-5 { margin-top: 5px; }
    .mt-2 { margin-top: 2px; }
    .mb-10 { margin-bottom: 10px; }
    .mb-5 { margin-bottom: 5px; }
    .mb-2 { margin-bottom: 2px; }
      
    </style>
    </head>
    <body style="text-align:center;margin:auto">
        <div class="container" style="border-left:solid 1px #CCC; border-right:solid 1px #CCC; width:60%;margin-left:20%;text-align:center;">
            <div><center><img src="http://seller.zalfa.id/ui/app/assets/img/logo-1-1.png" height="50" /></center></div>

            <h3>Akun Anda berhasil dibuat</h3>

            <div style="border-top:solid 1px #CCC;border-bottom:solid 1px #CCC;padding:10px; width:50%; margin-left:25%">
                <dl>
                    <dt>Username</dt>
                    <dd>: <?=$user?></dd>
                    <dt>Password</dt>
                    <dd>: <?=$password?></dd>
                </dl>
            </div>
            <div style="border-bottom:solid 1px #CCC;padding:10px">
            Akun ini digunakan untuk login ke aplikasi Zalfa di <a href="http://seller.zalfa.id" target="_blank">http://seller.zalfa.id</a>. Simpan baik baik dan jaga kerahasiannya.
            <br><br>
            </div>
        </div>
    </body>

    
</html>
