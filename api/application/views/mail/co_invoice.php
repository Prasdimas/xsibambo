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
        width: 150px;
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
        <div class="container" style="border-left:solid 1px #CCC; border-right:solid 1px #CCC; width:60%;margin-left:20%;text-align:left;">
            <div><center><img src="http://seller.zalfa.id/ui/app/assets/img/logo-1-1.png" height="50" /></center></div>
            <p style="padding:5px">Dear <b><?=$M_CustomerName?></b>, kami ingatkan untuk melakukan pembayaran atas <b>Pemesanan</b> barang anda. Berikut informasi detailnya :</p>

            <div style="border-top:solid 1px #CCC;border-bottom:solid 1px #CCC;padding:10px;">
                <dl>
                    <dt>Nomor Invoice</dt>
                    <dd>: <?=$C_SoNumber?></dd>
                    <dt>Tanggal Invoice</dt>
                    <dd>: <?=$C_InvoiceDate?></dd>
                    <dt>Jatuh Tempo</dt>
                    <dd>: <b><?=$C_InvoiceExpired?></b></dd>
                </dl>
                <h3>TOTAL : Rp <?=number_format($C_SoTotal);?></h3>
            </div>
            
            <?php if ($M_PaymentTypeCode == 'IPAYMU.CS') { ?>
            <div style="border-bottom:solid 1px #CCC;padding:10px">
                <b><?=strtoupper($ipaymu->F_IpaymuChannel)?></b>
                <p class="mt-10 mb-2">Kode pembayaran</b>
                <h3 style="color:#2096F3; font-size:2em;" class="mt-2 mb-5"><?=$ipaymu->F_IpaymuTrxCode?></h3>
                <p class="mt-10 mb-5">Lakukan pembayaran ke kasir dengan menyebutkan pembayaran PLASAMALL dan kode pembayaran.</p>
                <p class="mt-5 mb-5">Nominal di atas belum termasuk biaya Alfamart / Indomaret.</p>
                <p class="mt-5 mb-5">Silahkan melakukan pembayaran sebelum <b><?=$ipaymu->F_IpaymuExpired?></b></p>
            </div>
            <?php } ?>

            <?php if ($M_PaymentTypeCode == 'IPAYMU.QRIS') { ?>
            <div style="border-bottom:solid 1px #CCC;padding:10px">
            
                <a href="<?= isset($qrimage)? $qrimage : ''; ?>" target="_blank">Tampilkan Kode QRIS</a>

            </div>
            <?php } ?>

            <?php if ($M_PaymentTypeCode == 'TRANSFER') { ?>
            <div style="border-bottom:solid 1px #CCC;padding:10px">
                <p class="mt-5 mb-10">Silahkan transfer ke salah satu rekening berikut :</p>
                <?php foreach ($account as $l => $w) { ?>
                <b><?=$w['bank_name']?></b>
                <p style="color:#2096F3" class="mt-2 mb-2">No. <?=$w['account_number']?></b>
                <p class="mt-2 mb-10">A/n <?=$w['account_name_only']?></p>
                <?php } ?>
                <!-- <b>BANK BCA</b>
                <p style="color:#2096F3" class="mt-2 mb-2">No. 234324234233</b>
                <p class="mt-2 mb-5">A/n Bayu Adhi Prakoso</p> -->
            </div>
            <?php } ?>

            <div style="border-bottom:solid 1px #CCC;padding:10px">
            Untuk melihat invoice secara lebih detail, silahkan unduh lampiran yang telah kami kirim beserta email ini.
            <br><br>
            </div>
        </div>
    </body>

    
</html>

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
    </style>