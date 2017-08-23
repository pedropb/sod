package geotech.document;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.WorkbookUtil;
import org.apache.poi.xssf.usermodel.XSSFFont;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

public class XlsxWriter {
	
	private Workbook wb;
	private CellStyle header;
	private CellStyle body;

	public static final int CELL_LIMIT = 32767;
	public static final int COLUMNS_LIMIT = 16384;
	public static final int ROWS_LIMIT = 1048576;
	
	public XlsxWriter() {
		wb = new XSSFWorkbook();
		
		Font headerFont = wb.createFont();
		headerFont.setFontName("Arial");
		headerFont.setFontHeightInPoints((short) 10);
		headerFont.setUnderline(XSSFFont.U_SINGLE);
		headerFont.setBoldweight(XSSFFont.BOLDWEIGHT_BOLD);
		
		header = wb.createCellStyle();
		header.setFillBackgroundColor(IndexedColors.GREY_50_PERCENT.getIndex());
		header.setWrapText(true);
		header.setAlignment(CellStyle.ALIGN_CENTER);
		header.setFont(headerFont);
		
		header.setBorderBottom(CellStyle.BORDER_THIN);
		header.setBottomBorderColor(IndexedColors.BLACK.getIndex());
		
		header.setBorderTop(CellStyle.BORDER_THIN);
		header.setTopBorderColor(IndexedColors.BLACK.getIndex());
		
		header.setBorderLeft(CellStyle.BORDER_THIN);
		header.setLeftBorderColor(IndexedColors.BLACK.getIndex());
		
		header.setBorderRight(CellStyle.BORDER_THIN);
		header.setRightBorderColor(IndexedColors.BLACK.getIndex());
		
		Font bodyFont = wb.createFont();
		bodyFont.setFontName("Arial");
		bodyFont.setFontHeightInPoints((short) 10);
		
		body = wb.createCellStyle();
		body.setWrapText(true);
		body.setFont(bodyFont);
		
		body.setBorderBottom(CellStyle.BORDER_THIN);
		body.setBottomBorderColor(IndexedColors.BLACK.getIndex());
		
		body.setBorderTop(CellStyle.BORDER_THIN);
		body.setTopBorderColor(IndexedColors.BLACK.getIndex());
		
		body.setBorderLeft(CellStyle.BORDER_THIN);
		body.setLeftBorderColor(IndexedColors.BLACK.getIndex());
		
		body.setBorderRight(CellStyle.BORDER_THIN);
		body.setRightBorderColor(IndexedColors.BLACK.getIndex());
	}

	public void write (File file, String sheetName, String[] headers, String[][] content) {
		boolean init = true;
		OutputStream out = null;
		
		try {
			out = new FileOutputStream(file);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			System.err.println("XlsxWriter error while initialising the file output stream.");
			init = false;
		}
		
		if (init)
			write(out, sheetName, headers, content);
		
	}
	
	public void write (OutputStream out, String sheetName, String[] headers, String[][] content) {
		String safeName = WorkbookUtil.createSafeSheetName(sheetName);
		
		Sheet sheet = wb.createSheet(safeName);
		
		// write header cells
		Row headerRow = sheet.createRow(0);
		for (int j = 0; j < headers.length && j < COLUMNS_LIMIT; j++) {
			Cell c = headerRow.createCell(j);
			c.setCellStyle(header);
			c.setCellValue(headers[j]);
		}
		
		// write content cells
		for (int i = 0; i < content.length && i < ROWS_LIMIT; i++) {
			Row row = sheet.createRow(i+1);
			for (int j = 0; j < content[i].length && j < COLUMNS_LIMIT; j++) {
				Cell c = row.createCell(j);
				c.setCellStyle(body);
				
				String s;
				if (content[i][j].length() > CELL_LIMIT) {
					s = content[i][j].substring(0, CELL_LIMIT - 6) + " ...";
				}
				else {
					s = content[i][j];
				}
				
				c.setCellValue(s);
			}
		}
		
		try {
			wb.write(out);
		} catch (IOException e) {
			e.printStackTrace();
			System.err.println("XlsxWriter error while writing the xls.");
		}
	}
	
}
