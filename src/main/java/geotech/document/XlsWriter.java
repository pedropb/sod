package geotech.document;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.Locale;

import jxl.Workbook;
import jxl.WorkbookSettings;
import jxl.format.Alignment;
import jxl.format.Border;
import jxl.format.BorderLineStyle;
import jxl.format.Colour;
import jxl.format.UnderlineStyle;
import jxl.write.Label;
import jxl.write.WritableCellFormat;
import jxl.write.WritableFont;
import jxl.write.WritableSheet;
import jxl.write.WritableWorkbook;
import jxl.write.WriteException;

public class XlsWriter {

	private WritableCellFormat header;
	private WritableCellFormat body;
	
	public static final int CELL_LIMIT = 32767;
	public static final int COLUMNS_LIMIT = 256;
	public static final int ROWS_LIMIT = 65536;
	
	public XlsWriter() {
		header = new WritableCellFormat(new WritableFont(WritableFont.ARIAL, 10, WritableFont.BOLD, false, UnderlineStyle.SINGLE));
		body = new WritableCellFormat(new WritableFont(WritableFont.ARIAL, 10));

		try {
			header.setBackground(Colour.GRAY_25);
			header.setWrap(true);
			header.setAlignment(Alignment.CENTRE);
			header.setBorder(Border.ALL, BorderLineStyle.THIN, Colour.BLACK);
			
			body.setWrap(true);
			body.setBorder(Border.ALL, BorderLineStyle.THIN, Colour.BLACK);
		} catch (WriteException e) {
			System.err.println("XlsWriter error while initialising the cell format.");
		}
	}

	public void write (File file, String sheetName, String[] headers, String[][] content){
		try {
			write(new FileOutputStream(file), sheetName, headers, content);
		} catch (FileNotFoundException e) {
			System.err.println("XlsWriter error while initialising the file output stream.");
		}
	}
	
	public void write (OutputStream out, String sheetName, String[] headers, String[][] content){
		WorkbookSettings wbSettings = new WorkbookSettings();
		wbSettings.setLocale(new Locale("pt", "BR"));
		
		try {
			WritableWorkbook workbook = Workbook.createWorkbook(out, wbSettings);
			workbook.createSheet(sheetName, 0);
			WritableSheet sheet = workbook.getSheet(0);
			
			// write header cells
			for (int j = 0; j < headers.length && j < XlsWriter.COLUMNS_LIMIT; j++)
				sheet.addCell(new Label(j, 0, headers[j], header));
			
			// write content cells
			for (int j = 0; j < content.length && j < XlsWriter.COLUMNS_LIMIT; j++) {
				for (int i = 0; i < content[j].length && i < XlsWriter.ROWS_LIMIT; i++) {
					String c;
					if (content[j][i].length() > XlsWriter.CELL_LIMIT) {
						c = content[j][i].substring(0, XlsWriter.CELL_LIMIT - 6) + " ...";
					}
					else {
						c = content[j][i];
					}
					
					sheet.addCell(new Label(j, i + 1, c, body));
				}
			}
				
					
			
			workbook.write();
			workbook.close();
		} catch (Exception e) {
			System.err.println("XlsWriter error while writing the xls.");
		} 
	}
	
	public void setHeaderBoder (boolean border){
		try {
			if (border)
				header.setBorder(Border.ALL, BorderLineStyle.THIN, Colour.BLACK);
			else
				header.setBorder(Border.NONE, BorderLineStyle.NONE);
		} catch (WriteException e) {
			System.err.println("XlsWriter error while setting header border.");
		}
	}
	
	public void setBodyBoder (boolean border){
		try {
			if (border)
				body.setBorder(Border.ALL, BorderLineStyle.THIN, Colour.BLACK);
			else
				body.setBorder(Border.NONE, BorderLineStyle.NONE);
		} catch (WriteException e) {
			System.err.println("XlsWriter error while setting body border.");
		}
	}
	
	public void setHeaderFontBoldStyle (boolean bold){
		WritableFont font = (WritableFont) header.getFont();
		try {
			font.setBoldStyle(WritableFont.BOLD);
			header.setFont(font);
		} catch (WriteException e) {
			System.err.println("XlsWriter error while setting header font bold style.");
		}
	}
	
	public void setBodyFontBoldStyle (boolean bold){
		WritableFont font = (WritableFont) body.getFont();
		try {
			font.setBoldStyle(WritableFont.BOLD);
			body.setFont(font);
		} catch (WriteException e) {
			System.err.println("XlsWriter error while setting body font bold style.");
		}
	}
	
	public void setHeaderWrap (boolean wrap){
		try {
			header.setWrap(wrap);
		} catch (WriteException e) {
			System.err.println("XlsWriter error while setting head wrap.");
		}
	}
	
	public void setBodyWrap (boolean wrap){
		try {
			body.setWrap(wrap);
		} catch (WriteException e) {
			System.err.println("XlsWriter error while setting body wrap.");
		}
	}
}
