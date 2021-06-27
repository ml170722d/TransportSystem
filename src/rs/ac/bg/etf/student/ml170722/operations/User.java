package rs.ac.bg.etf.student.ml170722.operations;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import rs.ac.bg.etf.student.ml170722.DB;
import rs.etf.sab.operations.UserOperations;

@SuppressWarnings("unused")
public class User implements UserOperations {

	@Override
	public int declareAdmin(String arg0) {
		int result = 2;

		String query = "INSERT INTO Admin (idU) VALUES ((select idU from dbUser where username=?))";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setString(1, arg0);

			if (statement.executeUpdate() > 0)
				result = 0;

		} catch (SQLException e) {
			// e.printStackTrace();

			if (e.getMessage().contains("duplicate key"))
				result = 1;
		}

		return result;
	}

	@Override
	public int deleteUsers(String... arg0) {

		StringBuilder tmp = new StringBuilder();
		for (String _tmp : arg0)
			tmp.append("?,");
		tmp.deleteCharAt(tmp.length() - 1);

		String query = String.format("DELETE FROM dbUser WHERE username IN (%s)", tmp.toString());
		int affectedRows = 0;

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			int cnt = 1;
			for (String username : arg0)
				statement.setString(cnt++, username);

			affectedRows = statement.executeUpdate();

		} catch (SQLException e) {
			// e.printStackTrace();
		}

		return affectedRows;
	}

	@Override
	public List<String> getAllUsers() {

		List<String> list = new ArrayList<String>();
		String query = "SELECT username FROM dbUser";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(resultSet.getString("username"));
			}

		} catch (SQLException e) {
			// e.printStackTrace();
		}
		return list;
	}

	@Override
	public Integer getSentPackages(String... arg0) {

		StringBuilder tmp = new StringBuilder();
		for (String _tmp : arg0)
			tmp.append("?,");

		tmp = tmp.deleteCharAt(tmp.length() - 1);

		String query = String.format("SELECT COUNT(username) as cnt FROM dbUser WHERE username IN (%s)",
				tmp.toString());
		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			int cnt = 1;
			for (String username : arg0) {
				statement.setString(cnt++, username);
			}

			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next())
				if (resultSet.getInt("cnt") == 0)
					return null;

		} catch (SQLException e1) {
			// e1.printStackTrace();
		}

		query = String.format("SELECT SUM(sentPackages) AS sum FROM dbUser WHERE username IN (%s)", tmp.toString());

		Integer sum = null;
		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			int cnt = 1;
			for (String username : arg0) {
				statement.setString(cnt++, username);
			}

			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next())
				sum = resultSet.getInt("sum");

		} catch (SQLException e) {
			// e.printStackTrace();
		}

		return sum;
	}

	@Override
	public boolean insertUser(String arg0, String arg1, String arg2, String arg3) {

		boolean success = false;
		String query = "INSERT INTO dbUser (username, firstname, lastname, "
				+ "password, sentPackages) VALUES (?, ?, ?, ?, ?)";

		try (PreparedStatement statement = DB.getInstance().getConnection().prepareStatement(query,
				PreparedStatement.RETURN_GENERATED_KEYS)) {

			statement.setString(1, arg0);
			statement.setString(2, arg1);
			statement.setString(3, arg2);
			statement.setString(4, arg3);
			statement.setInt(5, 0);

			statement.executeUpdate();
			ResultSet resultSet = statement.getGeneratedKeys();
			if (resultSet.next())
				success = true;

		} catch (SQLException e) {
			// e.printStackTrace();
		}

		return success;
	}

}
