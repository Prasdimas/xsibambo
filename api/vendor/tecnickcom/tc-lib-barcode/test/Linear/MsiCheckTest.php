<?php
/**
 * MsiCheckTest.php
 *
 * @since       2015-02-21
 * @category    Library
 * @package     Barcode
 * @author      Nicola Asuni <info@tecnick.com>
 * @copyright   2015-2015 Nicola Asuni - Tecnick.com LTD
 * @license     http://www.gnu.org/copyleft/lesser.html GNU-LGPL v3 (see LICENSE.TXT)
 * @link        https://github.com/tecnickcom/tc-lib-barcode
 *
 * This file is part of tc-lib-barcode software library.
 */

namespace Test\Linear;

use PHPUnit\Framework\TestCase;
use \Test\TestUtil;

/**
 * Barcode class test
 *
 * @since       2015-02-21
 * @category    Library
 * @package     Barcode
 * @author      Nicola Asuni <info@tecnick.com>
 * @copyright   2015-2015 Nicola Asuni - Tecnick.com LTD
 * @license     http://www.gnu.org/copyleft/lesser.html GNU-LGPL v3 (see LICENSE.TXT)
 * @link        https://github.com/tecnickcom/tc-lib-barcode
 */
class MsiCheckTest extends TestUtil
{
    protected function getTestObject()
    {
        return new \Com\Tecnick\Barcode\Barcode;
    }

    public function testGetGrid()
    {
        $testObj = $this->getTestObject();
        $bobj = $testObj->getBarcodeObj('MSI+', '0123456789ABCDEF');
        $grid = $bobj->getGrid();
        $expected = "110100100100100100100100110100100110100100100110110100110100100100110100110100110110100"
            ."1001101101101101001001001101001001101101001101001101001101101101101001001101101001101101101101"
            ."001101101101101001001001101001\n";
        $this->assertEquals($expected, $grid);
    }

    public function testInvalidInput()
    {
        $this->bcExpectException('\Com\Tecnick\Barcode\Exception');
        $testObj = $this->getTestObject();
        $testObj->getBarcodeObj('MSI+', 'GHI');
    }
}
