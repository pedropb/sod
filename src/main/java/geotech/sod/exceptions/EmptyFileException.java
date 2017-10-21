package geotech.sod.exceptions;

public class EmptyFileException extends Exception {
    static final long serialVersionUID = 1L;

    public EmptyFileException() {
        super("File is empty.");
    }

    public EmptyFileException(String message) {
        super(message);
    }
}