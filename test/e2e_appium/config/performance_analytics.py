#!/usr/bin/env python3
"""
Tracks historical performance data and provides insights for test optimization
"""

import sqlite3
import statistics
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional
from dataclasses import dataclass

from .logging_config import get_logger


@dataclass
class PerformanceMetric:
    """Performance metric data structure."""

    test_name: str
    operation_name: str
    duration_ms: int
    success: bool
    timestamp: datetime
    session_id: str
    environment: str = "unknown"
    device: str = "unknown"
    device_type: str = "unknown"  # tablet, phone, desktop
    platform: str = "unknown"  # android, ios, windows
    platform_version: str = "unknown"


@dataclass
class PerformanceAnalysis:
    """Performance analysis results."""

    test_name: str
    operation_name: str
    current_duration_ms: int
    average_duration_ms: float
    median_duration_ms: float
    min_duration_ms: int
    max_duration_ms: int
    performance_trend: str  # "improving", "degrading", "stable"
    percentile_ranking: float  # 0-100, where 100 is fastest
    total_runs: int
    success_rate: float

    @property
    def is_above_average(self) -> bool:
        """True if current run is slower than average."""
        return self.current_duration_ms > self.average_duration_ms

    @property
    def performance_delta_ms(self) -> int:
        """Difference from average in milliseconds."""
        return self.current_duration_ms - int(self.average_duration_ms)

    @property
    def performance_delta_percent(self) -> float:
        """Percentage difference from average."""
        if self.average_duration_ms == 0:
            return 0.0
        return (self.performance_delta_ms / self.average_duration_ms) * 100


class PerformanceAnalytics:
    """Performance analytics system."""

    def __init__(self, db_path: str = "logs/performance_analytics.db"):
        self.db_path = Path(db_path)
        self.logger = get_logger("performance.analytics")
        self._init_database()

    def _init_database(self):
        """Initialize the performance database."""
        self.db_path.parent.mkdir(exist_ok=True)

        with sqlite3.connect(self.db_path) as conn:
            # Create table with all columns
            conn.execute("""
                CREATE TABLE IF NOT EXISTS performance_metrics (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    test_name TEXT NOT NULL,
                    operation_name TEXT NOT NULL,
                    duration_ms INTEGER NOT NULL,
                    success BOOLEAN NOT NULL,
                    timestamp TEXT NOT NULL,
                    session_id TEXT,
                    environment TEXT,
                    device TEXT,
                    device_type TEXT,
                    platform TEXT,
                    platform_version TEXT,
                    created_at TEXT DEFAULT CURRENT_TIMESTAMP
                )
            """)

            # Check if we need to add missing columns (for existing databases)
            cursor = conn.execute("PRAGMA table_info(performance_metrics)")
            columns = [row[1] for row in cursor.fetchall()]

            missing_columns = [
                ("device_type", "TEXT"),
                ("platform", "TEXT"),
                ("platform_version", "TEXT"),
            ]

            for column_name, column_type in missing_columns:
                if column_name not in columns:
                    try:
                        conn.execute(
                            f"ALTER TABLE performance_metrics ADD COLUMN {column_name} {column_type}"
                        )
                        self.logger.info(f"Added missing column: {column_name}")
                    except sqlite3.OperationalError as e:
                        self.logger.debug(
                            f"Column {column_name} may already exist: {e}"
                        )

            conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_test_operation 
                ON performance_metrics(test_name, operation_name)
            """)

            conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_timestamp 
                ON performance_metrics(timestamp)
            """)

        self.logger.debug(f"Performance analytics database initialized: {self.db_path}")

    def record_performance(self, metric: PerformanceMetric) -> PerformanceAnalysis:
        """
        Record a performance metric and return analysis.

        Returns:
            PerformanceAnalysis with historical context
        """
        # Store the metric
        with sqlite3.connect(self.db_path) as conn:
            conn.execute(
                """
                INSERT INTO performance_metrics 
                (test_name, operation_name, duration_ms, success, timestamp, 
                 session_id, environment, device, device_type, platform, platform_version)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
                (
                    metric.test_name,
                    metric.operation_name,
                    metric.duration_ms,
                    metric.success,
                    metric.timestamp.isoformat(),
                    metric.session_id,
                    metric.environment,
                    metric.device,
                    metric.device_type,
                    metric.platform,
                    metric.platform_version,
                ),
            )

        # Generate analysis
        analysis = self._analyze_performance(
            metric.test_name, metric.operation_name, metric.duration_ms
        )

        # Log insights
        self._log_performance_insights(analysis)

        return analysis

    def _analyze_performance(
        self, test_name: str, operation_name: str, current_duration_ms: int
    ) -> PerformanceAnalysis:
        """Analyze performance against historical data."""

        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute(
                """
                SELECT duration_ms, success FROM performance_metrics
                WHERE test_name = ? AND operation_name = ?
                ORDER BY timestamp DESC
                LIMIT 100
            """,
                (test_name, operation_name),
            )

            historical_data = cursor.fetchall()

        if not historical_data:
            # First run
            return PerformanceAnalysis(
                test_name=test_name,
                operation_name=operation_name,
                current_duration_ms=current_duration_ms,
                average_duration_ms=current_duration_ms,
                median_duration_ms=current_duration_ms,
                min_duration_ms=current_duration_ms,
                max_duration_ms=current_duration_ms,
                performance_trend="baseline",
                percentile_ranking=100.0,
                total_runs=1,
                success_rate=100.0,
            )

        # Extract durations and success rates
        durations = [row[0] for row in historical_data]
        successes = [row[1] for row in historical_data]

        # Calculate statistics
        avg_duration = statistics.mean(durations)
        median_duration = statistics.median(durations)
        min_duration = min(durations)
        max_duration = max(durations)

        # Calculate percentile ranking (lower duration = higher percentile)
        better_count = sum(1 for d in durations if current_duration_ms <= d)
        percentile = (better_count / len(durations)) * 100

        # Calculate trend (last 10 vs previous 10)
        trend = self._calculate_trend(durations)

        # Success rate
        success_rate = (sum(successes) / len(successes)) * 100

        return PerformanceAnalysis(
            test_name=test_name,
            operation_name=operation_name,
            current_duration_ms=current_duration_ms,
            average_duration_ms=avg_duration,
            median_duration_ms=median_duration,
            min_duration_ms=min_duration,
            max_duration_ms=max_duration,
            performance_trend=trend,
            percentile_ranking=percentile,
            total_runs=len(durations) + 1,  # +1 for current run
            success_rate=success_rate,
        )

    def _calculate_trend(self, durations: List[int]) -> str:
        """Calculate performance trend."""
        if len(durations) < 10:
            return "insufficient_data"

        # Compare recent 5 runs vs previous 5 runs
        recent_avg = statistics.mean(durations[:5])
        previous_avg = statistics.mean(durations[5:10])

        diff_percent = ((recent_avg - previous_avg) / previous_avg) * 100

        if diff_percent <= -5:
            return "improving"
        elif diff_percent >= 5:
            return "degrading"
        else:
            return "stable"

    def _log_performance_insights(self, analysis: PerformanceAnalysis):
        """Log performance insights with structured formatting."""

        # Determine performance status
        if analysis.total_runs == 1:
            status_emoji = "🆕"
            status = "BASELINE"
        elif analysis.performance_delta_percent <= -10:
            status_emoji = "🚀"
            status = "EXCELLENT"
        elif analysis.performance_delta_percent <= 0:
            status_emoji = "✅"
            status = "GOOD"
        elif analysis.performance_delta_percent <= 20:
            status_emoji = "⚠️"
            status = "SLOW"
        else:
            status_emoji = "🐌"
            status = "VERY_SLOW"

        # Log main performance result
        self.logger.info(
            f"{status_emoji} Performance {status}: {analysis.operation_name} = {analysis.current_duration_ms}ms",
            extra={
                "performance_status": status,
                "current_duration_ms": analysis.current_duration_ms,
                "average_duration_ms": analysis.average_duration_ms,
                "delta_ms": analysis.performance_delta_ms,
                "delta_percent": analysis.performance_delta_percent,
                "percentile_ranking": analysis.percentile_ranking,
                "total_runs": analysis.total_runs,
                "operation_name": analysis.operation_name,
            },
        )

        # Log detailed analytics
        self.logger.debug(
            f"📊 Performance Analytics: avg={analysis.average_duration_ms:.0f}ms, "
            f"median={analysis.median_duration_ms:.0f}ms, "
            f"min={analysis.min_duration_ms}ms, max={analysis.max_duration_ms}ms, "
            f"trend={analysis.performance_trend}, runs={analysis.total_runs}",
            extra={
                "performance_analytics": {
                    "average_ms": analysis.average_duration_ms,
                    "median_ms": analysis.median_duration_ms,
                    "min_ms": analysis.min_duration_ms,
                    "max_ms": analysis.max_duration_ms,
                    "trend": analysis.performance_trend,
                    "success_rate": analysis.success_rate,
                    "percentile": analysis.percentile_ranking,
                }
            },
        )

    def get_performance_report(
        self, test_name: Optional[str] = None, days: int = 30
    ) -> Dict:
        """Generate comprehensive performance report."""

        since_date = datetime.now() - timedelta(days=days)

        with sqlite3.connect(self.db_path) as conn:
            if test_name:
                cursor = conn.execute(
                    """
                    SELECT test_name, operation_name, 
                           AVG(duration_ms) as avg_duration,
                           MIN(duration_ms) as min_duration,
                           MAX(duration_ms) as max_duration,
                           COUNT(*) as total_runs,
                           AVG(CASE WHEN success = 1 THEN 100.0 ELSE 0.0 END) as success_rate
                    FROM performance_metrics
                    WHERE test_name = ? AND timestamp >= ?
                    GROUP BY test_name, operation_name
                    ORDER BY avg_duration DESC
                """,
                    (test_name, since_date.isoformat()),
                )
            else:
                cursor = conn.execute(
                    """
                    SELECT test_name, operation_name, 
                           AVG(duration_ms) as avg_duration,
                           MIN(duration_ms) as min_duration,
                           MAX(duration_ms) as max_duration,
                           COUNT(*) as total_runs,
                           AVG(CASE WHEN success = 1 THEN 100.0 ELSE 0.0 END) as success_rate
                    FROM performance_metrics
                    WHERE timestamp >= ?
                    GROUP BY test_name, operation_name
                    ORDER BY avg_duration DESC
                """,
                    (since_date.isoformat(),),
                )

            results = cursor.fetchall()

        return {
            "report_period_days": days,
            "total_operations": len(results),
            "operations": [
                {
                    "test_name": row[0],
                    "operation_name": row[1],
                    "avg_duration_ms": row[2],
                    "min_duration_ms": row[3],
                    "max_duration_ms": row[4],
                    "total_runs": row[5],
                    "success_rate": row[6],
                }
                for row in results
            ],
        }

    def cleanup_old_data(self, days_to_keep: int = 90):
        """Clean up old performance data."""
        cutoff_date = datetime.now() - timedelta(days=days_to_keep)

        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute(
                """
                DELETE FROM performance_metrics 
                WHERE timestamp < ?
            """,
                (cutoff_date.isoformat(),),
            )

            deleted_count = cursor.rowcount

        if deleted_count > 0:
            self.logger.info(f"🧹 Cleaned up {deleted_count} old performance records")

        return deleted_count
