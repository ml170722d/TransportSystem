package rs.ac.bg.etf.student.ml170722.operations;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import rs.ac.bg.etf.student.ml170722.DB;
import rs.etf.sab.operations.CourierRequestOperation;

public class CourierRequest implements CourierRequestOperation {

	@Override
	public boolean changeVehicleInCourierRequest(String arg0, String arg1) {
		
		String query = "UPDATE Courier SET idV=(SELECT idV FROM Vehicle WHERE licencePlate=?) "
				+ "WHERE idU=(SELECT idU FROM dbUser WHERE username=?)";

		boolean success = false;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setString(1, arg0);
			statement.setString(2, arg1);

			if (statement.executeUpdate() > 0)
				success = true;

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return success;
	}

	@Override
	public boolean deleteCourierRequest(String arg0) {

		String query = "DELETE FROM Courier WHERE idU = (SELECT idU FROM dbUser WHERE username=?)";
		boolean affectedRows = false;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setString(1, arg0);

			if (statement.executeUpdate() > 0)
				affectedRows = true;

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return affectedRows;
	}

	@Override
	public List<String> getAllCourierRequests() {

		List<String> list = new ArrayList<String>();
		String query = "SELECT username FROM dbUser WHERE idU = (SELECT idU FROM Courier)";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(resultSet.getString("username"));
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public boolean grantRequest(String arg0) {

		boolean success = false;
		String query = "UPDATE Courier status=?, profit=?, deliveredPackages=? WHERE ("
				+ "SELECT idU FROM dbUser WHERE username=?" + ") = idU";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setInt(1, 0);
			statement.setInt(2, 0);
			statement.setInt(3, 0);
			statement.setString(4, arg0);

			statement.executeUpdate();
			ResultSet resultSet = statement.getGeneratedKeys();
			if (resultSet.next())
				success = true;

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return success;
	}

	@Override
	public boolean insertCourierRequest(String arg0, String arg1) {

		boolean success = false;
		String query = "INSERT INTO Courier (idV, status, profit, idU, deliveredPackages) VALUES ("
				+ "(SELECT idV FROM Vehicle WHERE licencePlate=?), ?, ?, "
				+ "(SELECT idU FROM dbUser WHERE username=?), ?)";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setString(1, arg1);
			statement.setNull(2, java.sql.Types.VARCHAR);
			statement.setNull(3, java.sql.Types.VARCHAR);
			statement.setString(4, arg0);
			statement.setNull(5, java.sql.Types.INTEGER);

			statement.executeUpdate();
			ResultSet resultSet = statement.getGeneratedKeys();
			if (resultSet.next())
				success = true;

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return success;
	}

}
