package rs.ac.bg.etf.student.ml170722;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * 
 * @author Luka Matovic
 * @version v1
 */
public class DB {

	private static DB db = null;

	private static final String username = "sa";
	private static final String password = "123";
	private static final String database = "TransportSystem";
	private static final String server = "localhost";
	private static final int port = 1433;

	private static final String URL = "jdbc:sqlserver://" + server + ":" + port + ";databaseName=" + database;

	Connection conn;

	private DB() throws SQLException {
		conn = DriverManager.getConnection(URL, username, password);
	}

	/**
	 * 
	 * @return instance of DB class
	 * @throws SQLException if a database access error occurs or the url is null
	 */
	public static DB getInstance() throws SQLException {
		if (db == null)
			db = new DB();
		return db;
	}

	/**
	 * 
	 * @return connection to database
	 */
	public Connection getConnection() {
		return conn;
	}

}
