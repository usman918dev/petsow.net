using System;
using System.Data;
using System.Data.SqlClient;

namespace WebApplication1.Helpers
{
    /// <summary>
    /// Helper class for handling paginated data operations
    /// </summary>
    public static class PaginationHelper
    {
        /// <summary>
        /// Executes a paginated query and returns both the data and total count
        /// </summary>
        /// <param name="connectionString">Database connection string</param>
        /// <param name="baseQuery">Base SQL query without ORDER BY clause</param>
        /// <param name="countQuery">Query to get total count</param>
        /// <param name="orderByClause">ORDER BY clause for sorting</param>
        /// <param name="parameters">SQL parameters</param>
        /// <param name="currentPage">Current page number (1-based)</param>
        /// <param name="pageSize">Number of records per page</param>
        /// <returns>PaginatedResult containing data and pagination info</returns>
        public static PaginatedResult GetPaginatedData(
            string connectionString,
            string baseQuery,
            string countQuery,
            string orderByClause,
            SqlParameter[] parameters,
            int currentPage,
            int pageSize)
        {
            var result = new PaginatedResult();

            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();

                // Get total count
                using (var countCommand = new SqlCommand(countQuery, connection))
                {
                    if (parameters != null)
                    {
                        foreach (var param in parameters)
                        {
                            countCommand.Parameters.Add(new SqlParameter(param.ParameterName, param.Value));
                        }
                    }
                    result.TotalRecords = (int)countCommand.ExecuteScalar();
                }

                // Get paginated data if there are records
                if (result.TotalRecords > 0)
                {
                    int offset = (currentPage - 1) * pageSize;
                    
                    string paginatedQuery = $@"
                        {baseQuery}
                        {orderByClause}
                        OFFSET {offset} ROWS
                        FETCH NEXT {pageSize} ROWS ONLY";

                    using (var dataCommand = new SqlCommand(paginatedQuery, connection))
                    {
                        if (parameters != null)
                        {
                            foreach (var param in parameters)
                            {
                                dataCommand.Parameters.Add(new SqlParameter(param.ParameterName, param.Value));
                            }
                        }

                        using (var adapter = new SqlDataAdapter(dataCommand))
                        {
                            result.Data = new DataTable();
                            adapter.Fill(result.Data);
                        }
                    }
                }
                else
                {
                    result.Data = new DataTable();
                }
            }

            return result;
        }

        /// <summary>
        /// Calculates pagination information
        /// </summary>
        public static PaginationInfo CalculatePagination(int totalRecords, int currentPage, int pageSize)
        {
            var info = new PaginationInfo
            {
                TotalRecords = totalRecords,
                CurrentPage = currentPage,
                PageSize = pageSize
            };

            info.TotalPages = totalRecords > 0 ? (int)Math.Ceiling((double)totalRecords / pageSize) : 0;
            info.HasPreviousPage = currentPage > 1;
            info.HasNextPage = currentPage < info.TotalPages;
            info.StartRecord = totalRecords > 0 ? ((currentPage - 1) * pageSize) + 1 : 0;
            info.EndRecord = Math.Min(currentPage * pageSize, totalRecords);

            return info;
        }

        /// <summary>
        /// Validates and corrects pagination parameters
        /// </summary>
        public static void ValidatePaginationParams(ref int currentPage, ref int pageSize, int maxPageSize = 100)
        {
            if (pageSize <= 0 || pageSize > maxPageSize)
                pageSize = 10;

            if (currentPage < 1)
                currentPage = 1;
        }
    }

    /// <summary>
    /// Contains the result of a paginated query
    /// </summary>
    public class PaginatedResult
    {
        public DataTable Data { get; set; }
        public int TotalRecords { get; set; }
    }

    /// <summary>
    /// Contains pagination calculation results
    /// </summary>
    public class PaginationInfo
    {
        public int TotalRecords { get; set; }
        public int CurrentPage { get; set; }
        public int PageSize { get; set; }
        public int TotalPages { get; set; }
        public bool HasPreviousPage { get; set; }
        public bool HasNextPage { get; set; }
        public int StartRecord { get; set; }
        public int EndRecord { get; set; }
    }
}