<?php

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

/* Exception class. */
require 'PHPMailer/src/Exception.php';

/* The main PHPMailer class. */
require 'PHPMailer/src/PHPMailer.php';

/* SMTP class, needed if you want to use SMTP. */
require 'PHPMailer/src/SMTP.php';

include_once "db.php";
$db = new db();
$conn = $db->connect();

$sql = "SELECT *
        FROM `s_email_schedule`
        WHERE S_EmailScheduleType = 'INVOICE'
        AND S_EmailScheduleSent = 'N'
        AND S_EmailScheduleIsActive = 'Y'
        LIMIT 1";
$stmt = $conn->prepare($sql);

$rst = $db->fetch_all($stmt);
if ($rst)
{
    foreach ($rst as $k => $v)
    {
        $sql = "SELECT * FROM l_invoice JOIN l_so ON L_InvoiceL_SoID = L_SoID
                JOIN m_customer ON L_SoM_CustomerID = M_CustomerID
                WHERE L_InvoiceID = {$v['S_EmailScheduleReffID']}";
        $stmt2 = $conn->prepare($sql);
        $rst2 = $db->fetch_single($stmt2);

        $mail = new PHPMailer(TRUE);

        // // SMTP configuration
        // $this->load->model('system/s_email');
        // $em = $this->s_email->get_rotate();
        $em = (object) ['email_username'=>'onecode.id@gmail.com','email_password'=>'kjvwquzhbprhiebr'];

        $mail->isSMTP();
        $mail->Host     = 'smtp.gmail.com';
        $mail->SMTPAuth = true;
        $mail->Username = $em->email_username;
        $mail->Password = $em->email_password;
        $mail->SMTPSecure = 'tls';
        $mail->Port     = 587;
        
        $mail->setFrom($em->email_username, 'Zalfa Miracle');
        // $mail->addReplyTo('onecode.id@gmail.com', 'CodexWorld');

        // Add a recipient
        $mail->addAddress($v['S_EmailScheduleAddress']);
        
        // Email subject
        $mail->Subject = 'Customer Invoice untuk '.$rst2['M_CustomerName'];
        
        // Set email format to HTML
        $mail->isHTML(true);
        
        // Email body content
        $mailContent = "<h1>Send HTML Email using SMTP in CodeIgniter</h1>
            <p>This is a test email sending using SMTP mail server with PHPMailer.</p>";
        // $mailContent = $this->load->view('mail/invoice', (array)$r, true);
        $mail->Body = $mailContent;
        
        // // Attachment
        $mail->addAttachment('/home/one/Web/uploads/invoices/'.$rst2['L_SoNumber'].'.pdf');

        // Send email
        if(!$mail->send()){
            echo 'Message could not be sent.';
            echo 'Mailer Error: ' . $mail->ErrorInfo;
        }else{
            echo 'Message has been sent';
        }
    }
}



?>