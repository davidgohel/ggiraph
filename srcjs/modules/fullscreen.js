import * as d3 from 'd3';

export default class FullscreenHandler {
  constructor(svgid, containerid, tooltipZindex) {
    this.svgid = svgid;
    this.containerid = containerid;
    this.modalId = svgid + '_fullscreen_modal';
    this.isOpen = false;
    this.boundHandleKeydown = this.handleKeydown.bind(this);
    // z-index must be >= tooltip z-index to appear above tooltips
    this.zindex = (tooltipZindex-1) || 9998;
    // Store original state for restoration
    this.originalParent = null;
    this.originalNextSibling = null;
    this.originalStyles = {};
  }

  init() {
    return true;
  }

  destroy() {
    this.closeModal();
  }

  getButtons() {
    const that = this;
    return [
      {
        key: 'fullscreen',
        block: 'misc',
        class: 'neutral',
        tooltip: 'fullscreen',
        icon: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 512 512'><g><polygon points='396,396 396,320 436,320 436,456 300,456 300,416 396,416'/><polygon points='116,396 192,396 192,456 56,456 56,320 116,320'/><polygon points='116,116 116,192 56,192 56,56 192,56 192,96 96,96'/><polygon points='396,116 320,116 320,56 456,56 456,192 396,192'/></g></svg>",
        onclick: function () {
          that.openModal();
        }
      }
    ];
  }

  openModal() {
    if (this.isOpen) return;
    this.isOpen = true;

    const svgElement = document.getElementById(this.svgid);
    if (!svgElement) return;

    // Store original position and styles for restoration
    this.originalParent = svgElement.parentNode;
    this.originalNextSibling = svgElement.nextSibling;
    this.originalStyles = {
      width: svgElement.style.width,
      height: svgElement.style.height,
      maxWidth: svgElement.style.maxWidth,
      maxHeight: svgElement.style.maxHeight
    };

    // Create the modal overlay
    const modal = d3
      .select('body')
      .append('div')
      .attr('id', this.modalId)
      .attr('class', 'ggiraph-fullscreen-modal')
      .style('z-index', this.zindex);

    // Create modal content container
    const content = modal
      .append('div')
      .attr('class', 'ggiraph-fullscreen-content');

    // Add close button
    content
      .append('button')
      .attr('class', 'ggiraph-fullscreen-close')
      .attr('type', 'button')
      .attr('aria-label', 'Close fullscreen')
      .html('&times;')
      .on('click', () => this.closeModal());

    // Move the original SVG into the modal (preserves all event handlers)
    svgElement.style.width = '100%';
    svgElement.style.height = '100%';
    svgElement.style.maxWidth = '100%';
    svgElement.style.maxHeight = '100%';
    content.node().appendChild(svgElement);

    // Add click handler on backdrop to close
    modal.on('click', (event) => {
      if (event.target === modal.node()) {
        this.closeModal();
      }
    });

    // Add keyboard listener for Escape
    document.addEventListener('keydown', this.boundHandleKeydown);
  }

  closeModal() {
    if (!this.isOpen) return;
    this.isOpen = false;

    const svgElement = document.getElementById(this.svgid);
    if (svgElement && this.originalParent) {
      // Restore original styles
      svgElement.style.width = this.originalStyles.width;
      svgElement.style.height = this.originalStyles.height;
      svgElement.style.maxWidth = this.originalStyles.maxWidth;
      svgElement.style.maxHeight = this.originalStyles.maxHeight;

      // Move SVG back to original position
      if (this.originalNextSibling) {
        this.originalParent.insertBefore(svgElement, this.originalNextSibling);
      } else {
        this.originalParent.appendChild(svgElement);
      }
    }

    // Remove modal
    d3.select('#' + this.modalId).remove();

    // Remove keyboard listener
    document.removeEventListener('keydown', this.boundHandleKeydown);

    // Clear stored references
    this.originalParent = null;
    this.originalNextSibling = null;
    this.originalStyles = {};
  }

  handleKeydown(event) {
    if (event.key === 'Escape') {
      this.closeModal();
    }
  }
}
