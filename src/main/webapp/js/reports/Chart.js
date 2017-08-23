/*
 * GTPlanner Component
 * Developed by Pedro Baracho 
 * pedropbaracho@gmail.com
 */
Ext.define('GTPlanner.reports.Chart', {
    extend: 'Ext.chart.Chart',
    alias: ['widget.gtpiechart'],
    
    animate: true,
    shadow: true,
    legend: {
        position: 'right'
    },
    insetPadding: 50,
    theme: 'Base',
    series: [{
        type: 'pie',
        field: 'quantity',
        showInLegend: true,
        highlight: {
          segment: {
            margin: 20
          }
        },
		tips: {
			trackMouse: true,
			renderer: function(record) {
				this.update(record.get('id') + ': ' + record.get('quantity'));
			}
		},
        label: {
            field: 'id',
            display: 'none'
        }
    }],
    
    width: 785,
    height: 540
});

