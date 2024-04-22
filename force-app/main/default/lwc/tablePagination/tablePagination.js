import { LightningElement, api } from "lwc";
import Next from "@salesforce/label/c.Next";
import Previous from "@salesforce/label/c.Previous";

export default class TablePagination extends LightningElement {
  @api totalrecords;
  totalPagesSize = 0;
  @api pagenumber = 1;
  @api pagesize;

  labels = { Next, Previous };

  get totalPages() {
    return this.calculateTotalPages();
  }

  calculateTotalPages() {
    this.totalPagesSize = Math.ceil(this.totalrecords / this.pagesize);
    return Array.from({ length: this.totalPagesSize }, (_, index) => {
      return { value: index + 1, isCurrent: index + 1 === this.pagenumber };
    });
  }

  refreshActivePage(page) {
    this.totalPages.forEach((item) => {
      item.isCurrent = item.value === page;
    });
  }

  get isFirstPage() {
    return this.pagenumber === 1;
  }
  get isLastPage() {
    return this.pagenumber === this.totalPagesSize;
  }

  previousPage() {
    if (!this.isFirstPage) {
      this.dispatchEvent(new CustomEvent("previouspage"));
    }
    this.refreshActivePage(this.pagenumber - 1);
  }

  nextPage() {
    if (!this.isLastPage) {
      this.dispatchEvent(new CustomEvent("nextpage"));
    }
    this.refreshActivePage(this.pagenumber + 1);
  }

  handleChangePage(event) {
    const page = parseInt(event.target.dataset.value, 10);

    this.dispatchEvent(
      new CustomEvent("changepage", {
        detail: page
      })
    );

    this.refreshActivePage(page);
  }
}
