<?php

class Projectdetail extends MY_Controller
{
    function __construct()
    {
        parent::__construct();

        $this->load->model('project/p_projectdetail');
        $this->load->helper('url');
    }

    function index()
    {
        return;
    }

    function search_timeline()
    {
        $r = $this->p_projectdetail->search_timeline($this->sys_input['id']);

        $this->sys_ok($r);
    }

    function search_data()
    {
        $r = $this->p_projectdetail->search_data($this->sys_input['id']);

        $this->sys_ok($r);
    }

    function status_timeline()
    {
        $r = $this->p_projectdetail->status_timeline();

        $this->sys_ok($r);
    }

    function save()
    {
        $this->sys_input['user_id'] = $this->sys_user['user_id'];
        // if (isset($this->sys_input['staff_id']))
        //     $r = $this->s_staff->save( $this->sys_input, $this->sys_input['staff_id'] );
        // else
        $r = $this->p_projectdetail->save($this->sys_input);

        if ($r->status == "OK")
            $this->sys_ok($_FILES);
        // $this->sys_ok($r->data);
        else
            $this->sys_error($r->message);
    }

    function save_attachment()
    {
        $r = $this->p_projectdetail->save_attachment($this->sys_input);

        if ($r)
            $this->sys_ok($this->sys_input);
        else
            $this->sys_error("Unexpexted error !");
    }

    function upload_file()
    {
        // Check if the file was uploaded without errors
        if ($_FILES['attachment_file']['error'] === UPLOAD_ERR_OK) {
            // Specify the directory where you want to save the uploaded file
            $uploadDirectory = getcwd() . '/uploads/';

            // Create the directory if it doesn't exist
            if (!file_exists($uploadDirectory)) {
                mkdir($uploadDirectory, 0777, true);
            }

            // Get the temporary file name of the uploaded file
            $tempFileName = $_FILES['attachment_file']['tmp_name'];
            $md5 = md5($tempFileName);

            // Get the original name of the uploaded file
            $originalFileName = basename($_FILES['attachment_file']['name']);

            // Generate a unique filename to avoid conflicts
            $uniqueFileName = uniqid() . '_' . $originalFileName;

            // Move the uploaded file to the desired location
            $targetFilePath = $uploadDirectory . $uniqueFileName;
            if (move_uploaded_file($tempFileName, $targetFilePath)) {
                // File was successfully uploaded and saved
                $this->sys_ok(['message' => 'File uploaded successfully.', 'md5' => $md5, 'filename' => $uniqueFileName]);
            } else {
                // Failed to move the uploaded file
                echo 'Error: Failed to move uploaded file.';
            }
        } else {
            // Error occurred during file upload
            echo 'Error: ' . $_FILES['attachment_file']['error'];
        }
    }

    function remove_attachment()
    {
        $x = $this->delete_file($this->sys_input['filename']);
        if ($x)
            $this->p_projectdetail->remove_attachment($this->sys_input);

        $this->sys_ok($this->sys_input);
    }

    function delete_file($filePath)
    {
        $fileToDelete = getcwd() . '/uploads/' . $filePath;

        // Check if the file exists before attempting to delete it
        if (file_exists($fileToDelete)) {
            // Attempt to delete the file
            if (unlink($fileToDelete)) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
}
