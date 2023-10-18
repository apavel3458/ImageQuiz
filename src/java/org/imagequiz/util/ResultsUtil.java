package org.imagequiz.util;

import java.util.ArrayList;
import java.util.List;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.RichTextString;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;

public class ResultsUtil {

	public static void transpose(Workbook wb, int sheetNum, boolean replaceOriginalSheet) {
	    Sheet sheet = wb.getSheetAt(sheetNum);

	    Pair<Integer, Integer> lastRowColumn = getLastRowAndLastColumn(sheet);
	    int lastRow = lastRowColumn.getFirst();
	    int lastColumn = lastRowColumn.getSecond();


	    List<CellModel> allCells = new ArrayList<CellModel>();
	    for (int rowNum = 0; rowNum <= lastRow; rowNum++) {
	        Row row = sheet.getRow(rowNum);
	        if (row == null) {
	            continue;
	        }
	        for (int columnNum = 0; columnNum < lastColumn; columnNum++) {
	            Cell cell = row.getCell(columnNum);
	            allCells.add(new CellModel(cell));
	        }
	    }

	    Sheet tSheet = wb.createSheet(sheet.getSheetName() + "_transposed");
	    for (CellModel cm : allCells) {
	        if (cm.isBlank()) {
	            continue;
	        }

	        int tRow = cm.getColNum();
	        int tColumn = cm.getRowNum();

	        Row row = tSheet.getRow(tRow);
	        if (row == null) {
	            row = tSheet.createRow(tRow);
	        }

	        Cell cell = row.createCell(tColumn);
	        cm.insertInto(cell);
	    }

	    lastRowColumn = getLastRowAndLastColumn(sheet);
	    lastRow = lastRowColumn.getFirst();
	    lastColumn = lastRowColumn.getSecond();

	    if (replaceOriginalSheet) {
	        int pos = wb.getSheetIndex(sheet);
	        wb.removeSheetAt(pos);
	        wb.setSheetOrder(tSheet.getSheetName(), pos);
	    }

	}

	private static Pair<Integer, Integer> getLastRowAndLastColumn(Sheet sheet) {
	    int lastRow = sheet.getLastRowNum();
	    int lastColumn = 0;
	    for (Row row : sheet) {
	        if (lastColumn < row.getLastCellNum()) {
	            lastColumn = row.getLastCellNum();
	        }
	    }
	    return new Pair<Integer, Integer>(lastRow, lastColumn);
	}
	
	static class Pair<F, S> {
		F f;
		S s;
		public Pair(F f, S s) {
			this.f = f;
			this.s = s;
		}
		public F getFirst() { return f; }
		public S getSecond() { return s; }
		public void setFirst(F f) { this.f = f; }
		public void setSecond(S s) { this.s = s; }
	}
	
	static class CellModel {
	    private int rowNum = -1;
	    private int colNum = -1;
	    private CellStyle cellStyle;
	    private int cellType = -1;
	    private Object cellValue;

	    public CellModel(Cell cell) {
	        if (cell != null) {
	            this.rowNum = cell.getRowIndex();
	            this.colNum = cell.getColumnIndex();
	            this.cellStyle = cell.getCellStyle();
	            this.cellType = cell.getCellType();
	            switch (this.cellType) {
	                case Cell.CELL_TYPE_BLANK:
	                    break;
	                case Cell.CELL_TYPE_BOOLEAN:
	                    cellValue = cell.getBooleanCellValue();
	                    break;
	                case Cell.CELL_TYPE_ERROR:
	                    cellValue = cell.getErrorCellValue();
	                    break;
	                case Cell.CELL_TYPE_FORMULA:
	                    cellValue = cell.getCellFormula();
	                    break;
	                case Cell.CELL_TYPE_NUMERIC:
	                    cellValue = cell.getNumericCellValue();
	                    break;
	                case Cell.CELL_TYPE_STRING:
	                    cellValue = cell.getRichStringCellValue();
	                    break;
	            }
	        }
	    }

	    public boolean isBlank() {
	        return this.cellType == -1 && this.rowNum == -1 && this.colNum == -1;
	    }

	    public void insertInto(Cell cell) {
	        if (isBlank()) {
	            return;
	        }

	        cell.setCellStyle(this.cellStyle);
	        cell.setCellType(this.cellType);
	        switch (this.cellType) {
	            case Cell.CELL_TYPE_BLANK:
	                break;
	            case Cell.CELL_TYPE_BOOLEAN:
	                cell.setCellValue((boolean) this.cellValue);
	                break;
	            case Cell.CELL_TYPE_ERROR:
	                cell.setCellErrorValue((byte) this.cellValue);
	                break;
	            case Cell.CELL_TYPE_FORMULA:
	                cell.setCellFormula((String) this.cellValue);
	                break;
	            case Cell.CELL_TYPE_NUMERIC:
	                cell.setCellValue((double) this.cellValue);
	                break;
	            case Cell.CELL_TYPE_STRING:
	                cell.setCellValue((RichTextString) this.cellValue);
	                break;
	        }
	    }

	    public CellStyle getCellStyle() {
	        return cellStyle;
	    }

	    public int getCellType() {
	        return cellType;
	    }

	    public Object getCellValue() {
	        return cellValue;
	    }

	    public int getRowNum() {
	        return rowNum;
	    }

	    public int getColNum() {
	        return colNum;
	    }

	}
}
