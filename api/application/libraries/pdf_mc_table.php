<?php
class PDF_MC_Table extends FPDI
{

var $widths;
var $aligns;
var $height;
var $rects;
var $boxes;
var $fills;
var $fills_color;


function SetWidths($w)
{
    //Set the array of column widths
    $this->widths=$w;
}

function setFills($w)
{
    //Set the array of column widths
    $this->fills=$w;
}

function SetAligns($a)
{
    //Set the array of column alignments
    $this->aligns=$a;
}
function setRect($r) {
	$this->rects = $r;
}
function setHeight($r) {
	$this->height = $r;
}


function Row($data)
{
    //Calculate the height of the row
    $nb=0;
    for($i=0;$i<count($data);$i++)
        $nb=max($nb,$this->NbLines($this->widths[$i],$data[$i]));
    $h=5*$nb;
    if ($this->k == 72/2.54 ) $h=0.5*$nb;
    //Issue a page break first if needed
    $this->CheckPageBreak($h);
    //Draw the cells of the row
    for($i=0;$i<count($data);$i++)
    {
        $w=$this->widths[$i];
        $a=isset($this->aligns[$i]) ? $this->aligns[$i] : 'L';
        //Save the current position
        $x=$this->GetX();
        $y=$this->GetY();
        //Draw the border
		if ( isset ( $this->fills ) ) {
			if ( $this->fills[$i] )  {
				if ( $this->fills_color ) {
					$this->setFillColor($this->fills_color[0],$this->fills_color[1],$this->fills_color[2]);
				} else {
   				$this->setFillColor(220,220,220);
   			}
				$this->Rect($x, $y, $w, $h, "F" );
			}
		}
		if ( isset( $this->boxes ) ) {
			if ( stripos( $this->boxes[$i] , "L" ) !== FALSE  ) $this->Line($x, $y, $x, $y + $h);
			if ( stripos( $this->boxes[$i] , "R" ) !== FALSE  ) $this->Line($x + $w , $y, $x + $w , $y + $h  );
			if ( stripos( $this->boxes[$i] , "T" ) !== FALSE  ) $this->Line($x, $y, $x + $w , $y  );
			if ( stripos( $this->boxes[$i] , "B" ) !== FALSE  ) $this->Line($x  , $y +$h , $x + $w , $y  + $h );
		} elseif ( isset($this->rects ) ) {
			if ( $this->rects[$i] ) $this->Rect($x, $y, $w, $h);
		} else {
			$this->Rect($x, $y, $w, $h);
		}

        //Print the text
        $this->MultiCell($w,$h,$data[$i],0,$a);
        //Put the position to the right of the cell
        $this->SetXY($x+$w,$y);
    }
    //Go to the next line
    $this->Ln($h);
}

function CheckPageBreak($h)
{
    //If the height h would cause an overflow, add a new page immediately
    if($this->GetY()+$h>$this->PageBreakTrigger)
        $this->AddPage($this->CurOrientation);
}

function NbLines($w,$txt)
{
    //Computes the number of lines a MultiCell of width w will take
    $cw=&$this->CurrentFont['cw'];
    if($w==0)
        $w=$this->w-$this->rMargin-$this->x;
    $wmax=($w-2*$this->cMargin)*1000/$this->FontSize;
    $s=str_replace("\r",'',$txt);
    $nb=strlen($s);
    if($nb>0 and $s[$nb-1]=="\n")
        $nb--;
    $sep=-1;
    $i=0;
    $j=0;
    $l=0;
    $nl=1;
    while($i<$nb)
    {
        $c=$s[$i];
        if($c=="\n")
        {
            $i++;
            $sep=-1;
            $j=$i;
            $l=0;
            $nl++;
            continue;
        }
        if($c==' ')
            $sep=$i;
        $l+=$cw[$c];
        if($l>$wmax)
        {
            if($sep==-1)
            {
                if($i==$j)
                    $i++;
            }
            else
                $i=$sep+1;
            $sep=-1;
            $j=$i;
            $l=0;
            $nl++;
        }
        else
            $i++;
    }
    return $nl;
}
}
?>
