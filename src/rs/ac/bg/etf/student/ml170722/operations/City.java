package rs.ac.bg.etf.student.ml170722.operations;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import rs.ac.bg.etf.student.ml170722.DB;
import rs.etf.sab.operations.CityOperations;

/**
 * 
 * @author Luka Matovic
 * @version v1
 *
 */
public class City implements CityOperations {

	@Override
	public int deleteCity(String... arg0) {
		int affectedRows = 0;
		String query = "DELETE FROM City WHERE name=?";

		for (String city : arg0) {
			try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
					PreparedStatement.RETURN_GENERATED_KEYS)) {

				statement.setString(1, city);
				affectedRows += statement.executeUpdate();

			} catch (SQLException e) {
				// e.printStackTrace();
			}
		}

		return affectedRows;
	}

	@Override
	public boolean deleteCity(int arg0) {
		String query = "DELETE FROM City WHERE idC=?";
		boolean affectedRows = false;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg0);
			if (statement.executeUpdate() > 0)
				affectedRows = true;

		} catch (SQLException e) {
			// e.printStackTrace();
		}

		return affectedRows;
	}

	@Override
	public List<Integer> getAllCities() {

		List<Integer> cityIDs = new ArrayList<Integer>();

		try (Statement statement = DB.getInstance().getConnection().createStatement()) {

			String query = "SELECT * FROM City";

			ResultSet resultSet = statement.executeQuery(query);

			while (resultSet.next()) {
				cityIDs.add(resultSet.getInt("idC"));
			}

		} catch (SQLException e) {
			// e.printStackTrace();
		}

		return cityIDs;
	}

	@Override
	public int insertCity(String arg0, String arg1) {
		int insertedID = -1;
		String query = "INSERT INTO City(name, postalCode) VALUES(?, ?)";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {
			statement.setString(1, arg0);
			statement.setString(2, arg1);

			statement.executeUpdate();
			ResultSet resultSet = statement.getGeneratedKeys();
			if (resultSet.next())
				insertedID = resultSet.getInt(1);

		} catch (SQLException e) {
			// e.printStackTrace();
		}
		return insertedID;
	}

}
