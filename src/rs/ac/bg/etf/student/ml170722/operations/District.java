package rs.ac.bg.etf.student.ml170722.operations;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import rs.ac.bg.etf.student.ml170722.DB;
import rs.etf.sab.operations.DistrictOperations;

public class District implements DistrictOperations {

	@Override
	public int deleteAllDistrictsFromCity(String arg0) {
		int affectedRows = 0;

		String queryDistrictIDs = "DELETE FROM District WHERE idC = ( SELECT c.idC FROM City c WHERE c.name=? )";
		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(queryDistrictIDs,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setString(1, arg0);
			affectedRows = statement.executeUpdate();

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return affectedRows;
	}

	@Override
	public boolean deleteDistrict(int arg0) {
		String query = "DELETE FROM District WHERE idD=?";
		boolean isAffected = false;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg0);
			if (statement.executeUpdate() > 0)
				isAffected = true;

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return isAffected;
	}

	@Override
	public int deleteDistricts(String... arg0) {
		int affectedRows = 0;
		String query = "DELETE FROM District WHERE name=?";

		for (String district : arg0) {
			try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
					PreparedStatement.RETURN_GENERATED_KEYS)) {

				statement.setString(1, district);
				affectedRows += statement.executeUpdate();

			} catch (SQLException e) {
				e.printStackTrace();
			}
		}

		return affectedRows;
	}

	@Override
	public List<Integer> getAllDistricts() {
		List<Integer> districtIDs = new ArrayList<Integer>();

		try (Statement statement = DB.getInstance().getConnection().createStatement()) {

			String query = "SELECT * FROM Distict";

			ResultSet resultSet = statement.executeQuery(query);

			while (resultSet.next()) {
				districtIDs.add(resultSet.getInt("idC"));
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return districtIDs;
	}

	@Override
	public List<Integer> getAllDistrictsFromCity(int arg0) {
		List<Integer> districtIDs = new ArrayList<Integer>();
		String query = "SELECT idD FROM District WHERE idC=?";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, arg0);
			ResultSet resultSet = statement.executeQuery();

			while (resultSet.next()) {
				districtIDs.add(resultSet.getInt("idD"));
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return districtIDs;
	}

	@Override
	public int insertDistrict(String arg0, int arg1, int arg2, int arg3) {
		String query = "INSERT INTO District (name, X, Y, idC) VALUES (?, ?, ?, ?)";
		int affectedRow = -1;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {
			
			statement.setString(1, arg0);
			statement.setInt(4, arg1);
			statement.setInt(2, arg2);
			statement.setInt(3, arg3);
			
			statement.executeUpdate();
			ResultSet resultSet = statement.getGeneratedKeys();
			if (resultSet.next())
				affectedRow = resultSet.getInt(1);
		
		} catch (SQLException e) {
			e.printStackTrace();
		}
		
		return affectedRow;
	}

}
