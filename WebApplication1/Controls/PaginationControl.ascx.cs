using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebApplication1.Controls
{
    public partial class PaginationControl : UserControl
    {
        #region Events
        public event EventHandler<PageChangedEventArgs> PageChanged;
        public event EventHandler<PageSizeChangedEventArgs> PageSizeChanged;
        #endregion

        #region Properties
        public int CurrentPage
        {
            get { return ViewState["CurrentPage"] != null ? (int)ViewState["CurrentPage"] : 1; }
            set { ViewState["CurrentPage"] = value; }
        }

        public int PageSize
        {
            get { return ViewState["PageSize"] != null ? (int)ViewState["PageSize"] : 10; }
            set 
            { 
                ViewState["PageSize"] = value;
                ddlPageSize.SelectedValue = value.ToString();
            }
        }

        public int TotalRecords
        {
            get { return ViewState["TotalRecords"] != null ? (int)ViewState["TotalRecords"] : 0; }
            set { ViewState["TotalRecords"] = value; }
        }

        public int TotalPages
        {
            get
            {
                if (TotalRecords == 0) return 0;
                return (int)Math.Ceiling((double)TotalRecords / PageSize);
            }
        }

        public bool ShowPageSizeSelector
        {
            get { return ViewState["ShowPageSizeSelector"] != null ? (bool)ViewState["ShowPageSizeSelector"] : true; }
            set { ViewState["ShowPageSizeSelector"] = value; }
        }

        public int MaxVisiblePages { get; set; } = 5;
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PageSize = 10; // Default page size
            }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            UpdatePaginationDisplay();
        }

        private void UpdatePaginationDisplay()
        {
            // Hide pagination if no records or only one page
            bool showPagination = TotalRecords > 0 && TotalPages > 1;
            paginationWrapper.Visible = showPagination;
            mobilePagination.Visible = showPagination;

            if (!showPagination) return;

            // Update page info
            int startRecord = ((CurrentPage - 1) * PageSize) + 1;
            int endRecord = Math.Min(CurrentPage * PageSize, TotalRecords);

            lblStartRecord.Text = startRecord.ToString();
            lblEndRecord.Text = endRecord.ToString();
            lblTotalRecords.Text = TotalRecords.ToString();

            // Update mobile labels
            lblMobileCurrentPage.Text = CurrentPage.ToString();
            lblMobileTotalPages.Text = TotalPages.ToString();
            lblMobileTotalRecords.Text = TotalRecords.ToString();

            // Update navigation buttons
            bool hasPrevious = CurrentPage > 1;
            bool hasNext = CurrentPage < TotalPages;

            liPrevious.Visible = hasPrevious;
            btnPrevious.Enabled = hasPrevious;
            btnMobilePrevious.Enabled = hasPrevious;

            liNext.Visible = hasNext;
            btnNext.Enabled = hasNext;
            btnMobileNext.Enabled = hasNext;

            // Build page numbers
            BuildPageNumbers();

            // Show/hide page size selector
            ddlPageSize.Parent.Visible = ShowPageSizeSelector;
        }

        private void BuildPageNumbers()
        {
            var pageNumbers = new List<PageNumberInfo>();

            // Calculate the range of pages to show
            int startPage = Math.Max(1, CurrentPage - (MaxVisiblePages / 2));
            int endPage = Math.Min(TotalPages, startPage + MaxVisiblePages - 1);

            // Adjust start page if we're near the end
            if (endPage - startPage < MaxVisiblePages - 1)
            {
                startPage = Math.Max(1, endPage - MaxVisiblePages + 1);
            }

            // Add first page and ellipsis if needed
            if (startPage > 1)
            {
                pageNumbers.Add(new PageNumberInfo { PageNumber = 1 });
                if (startPage > 2)
                {
                    pageNumbers.Add(new PageNumberInfo { PageNumber = -1, DisplayText = "..." }); // Ellipsis
                }
            }

            // Add visible pages
            for (int i = startPage; i <= endPage; i++)
            {
                pageNumbers.Add(new PageNumberInfo { PageNumber = i });
            }

            // Add ellipsis and last page if needed
            if (endPage < TotalPages)
            {
                if (endPage < TotalPages - 1)
                {
                    pageNumbers.Add(new PageNumberInfo { PageNumber = -1, DisplayText = "..." }); // Ellipsis
                }
                pageNumbers.Add(new PageNumberInfo { PageNumber = TotalPages });
            }

            rptPageNumbers.DataSource = pageNumbers;
            rptPageNumbers.DataBind();
        }

        protected void btnPrevious_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1)
            {
                CurrentPage--;
                OnPageChanged();
            }
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            if (CurrentPage < TotalPages)
            {
                CurrentPage++;
                OnPageChanged();
            }
        }

        protected void rptPageNumbers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "PageNumber")
            {
                int pageNumber = Convert.ToInt32(e.CommandArgument);
                if (pageNumber > 0 && pageNumber <= TotalPages && pageNumber != CurrentPage)
                {
                    CurrentPage = pageNumber;
                    OnPageChanged();
                }
            }
        }

        protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            int newPageSize = Convert.ToInt32(ddlPageSize.SelectedValue);
            if (newPageSize != PageSize)
            {
                PageSize = newPageSize;
                CurrentPage = 1; // Reset to first page when page size changes
                OnPageSizeChanged();
            }
        }

        private void OnPageChanged()
        {
            PageChanged?.Invoke(this, new PageChangedEventArgs(CurrentPage, PageSize));
        }

        private void OnPageSizeChanged()
        {
            PageSizeChanged?.Invoke(this, new PageSizeChangedEventArgs(PageSize, CurrentPage));
        }

        public void SetPaginationData(int totalRecords, int currentPage = 1, int pageSize = 10)
        {
            TotalRecords = totalRecords;
            CurrentPage = currentPage;
            PageSize = pageSize;
            ddlPageSize.SelectedValue = pageSize.ToString();
        }

        public void Reset()
        {
            CurrentPage = 1;
            TotalRecords = 0;
            UpdatePaginationDisplay();
        }
    }

    #region Helper Classes
    public class PageNumberInfo
    {
        public int PageNumber { get; set; }
        public string DisplayText { get; set; }

        public PageNumberInfo()
        {
            DisplayText = PageNumber > 0 ? PageNumber.ToString() : "...";
        }
    }

    public class PageChangedEventArgs : EventArgs
    {
        public int CurrentPage { get; }
        public int PageSize { get; }

        public PageChangedEventArgs(int currentPage, int pageSize)
        {
            CurrentPage = currentPage;
            PageSize = pageSize;
        }
    }

    public class PageSizeChangedEventArgs : EventArgs
    {
        public int PageSize { get; }
        public int CurrentPage { get; }

        public PageSizeChangedEventArgs(int pageSize, int currentPage)
        {
            PageSize = pageSize;
            CurrentPage = currentPage;
        }
    }
    #endregion
}