# StudyU: N-of-1 Trials Results Visualization <img src="https://www.studyu.health/img/logo.png" height="50" align="right" alt="StudyU Icon">

As part of our master's project at the **[Hasso Plattner Institute](https://hpi.de/en/)**, we have redesigned and implemented the results visualization for N-of-1 trials in the **[StudyU.health](https://www.studyu.health)** application. Based on anonymous questionnaires, user feedback, and iterative feedback, we have developed the following features:

<img src="https://github.com/user-attachments/assets/c392bd60-61cd-472b-88a5-98b46e893bd6" height="450" align="right">

### 1. Textual Summary
The results visualization begins with a short textual summary based on a two-sample t-test (Welch's t-test). This summary provides an easy-to-understand explanation of the final results.
- **Info Tab**: For those interested in the statistical details, an info tab is available within the summary. It displays the significance level used (alpha fixed at 5%) and the p-value of the t-test.

### 2. Gauge Graphs
The next section presents two **gauge graphs** showing the average outcome of each intervention.
- **Customization Options**: Participants can switch between colorful or colorless gauges, accommodating those with visual sensitivities.

### 3. Bar vs. Line Plots
In the third section, participants can explore data over different time intervals, including per day, phase, or intervention.

### 4. Descriptive Statistics
For participants interested in statistical details, we also provide additional descriptive statistics. This section includes the number of missing observations and other relevant metrics that help give a deeper understanding of the data.

---
### Updates

Feel free to check out updates on our branch in the [original repository](https://github.com/hpi-studyu/studyu/tree/dev_results_visualization) or explore the code and features in this **fork**.
