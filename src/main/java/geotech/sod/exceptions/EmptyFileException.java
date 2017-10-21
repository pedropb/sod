package geotech.sod.exceptions;

public class EmptyFileException extends Exception {
    static final long serialVersionUID = 1L;

    public EmptyFileException() {
        super("Arquivo está vazio.");
    }

    public EmptyFileException(String message) {
        super(message);
    }
}