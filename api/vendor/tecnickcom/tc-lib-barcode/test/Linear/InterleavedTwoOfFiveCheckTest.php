<?php
/**
 * InterleavedTwoOfFiveCheckTest.php
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
class InterleavedTwoOfFiveCheckTest extends TestUtil
{
    protected function getTestObject()
    {
        return new \Com\Tecnick\Barcode\Barcode;
    }

    public function testGetGrid()
    {
        $testObj = $this->getTestObject();
        $bobj = $testObj->getBarcodeObj(
            'I25+',
            '0123456789'
        );
        $grid = $bobj->getGrid();
        $expected = "10101010110011001011010010101100110110100101001101001100101010010101100110100110100110101101\n";
        $this->assertEquals($expected, $grid);
    }

    public function testInvalidInput()
    {
        $this->bcExpectException('\Com\Tecnick\Barcode\Exception');
        $testObj = $this->getTestObject();
        $testObj->getBarcodeObj('I25+', 'GHI');
    }
}
