package rs.ac.bg.etf.student.ml170722.operations;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import rs.ac.bg.etf.student.ml170722.DB;
import rs.etf.sab.operations.GeneralOperations;

public class General implements GeneralOperations {

	@Override
	public void eraseAll() {
		Connection connection;
		try {
			connection = DB.getInstance().getConnection();
		} catch (SQLException e1) {
			e1.printStackTrace();
			System.err.println("Couldn't connect to database");
			return;
		}
		
		{
			// delete content of City table
			String query = "DELETE FROM City";
			try (PreparedStatement statement = connection.prepareStatement(query)) {

				statement.executeUpdate();

			} catch (SQLException e) {
				e.printStackTrace();
			}
			
			// cascades to District table
		}
		
		{
			// delete content of Vehicle table
			String query = "DELETE FROM Vehicle";
			try (PreparedStatement statement = connection.prepareStatement(query)){
				
				statement.executeUpdate();
			
			} catch (SQLException e) {
				e.printStackTrace();
			}
			
			// cascades to Courier table
		}
		
		{
			// delete content of dbUser table
			String query = "DELETE FROM dbUser";
			try (PreparedStatement statement = connection.prepareStatement(query)){
				
				statement.executeUpdate();
			
			} catch (SQLException e) {
				e.printStackTrace();
			}
			
			// cascades to Courier table 
			// cascades to Admin table 
		}
		
	}

}
