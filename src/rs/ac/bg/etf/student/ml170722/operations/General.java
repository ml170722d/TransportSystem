package rs.ac.bg.etf.student.ml170722.operations;

import java.sql.CallableStatement;
import java.sql.SQLException;

import rs.ac.bg.etf.student.ml170722.DB;
import rs.etf.sab.operations.GeneralOperations;

public class General implements GeneralOperations {

	@Override
	public void eraseAll() {
		
		String query = "{call sp_emptyDB}";
		try (CallableStatement statement = DB.getInstance().getConnection().prepareCall(query)) {
			statement.execute();
		} catch (SQLException e) {
//			e.printStackTrace();
			System.err.println(e.getMessage());
		}
		
	}

}
