new Chart('student-population-chart', {
  type: 'bar',
  options: {
    scales: {
      yAxes: [{
        ticks: {
          callback: function(value) {
            return value;
          },
          stepSize: 100,
        }
      }]
    }
  },
  data: {
    labels: ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6'],
    datasets: [{
      label: 'All',
      data: [200, 220, 230, 200, 240, 200]
    },{
      label: 'Male',
      data: [83, 100, 100, 80, 100, 100],
               hidden: true
    },{
      label: 'Female',
      data: [117, 120, 130, 120, 140, 100],
               hidden: true
    }]
  }
});
