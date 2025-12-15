# Base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY src/ src/
COPY tests/ tests/
COPY docs/ docs/
COPY Doxyfile .

# Install LaTeX, Doxygen, Graphviz, and zip
RUN apt-get update && apt-get install -y \
    texlive-latex-base \
    doxygen \
    graphviz \
    zip \
    git \
    && apt-get clean

# ARG for major/minor version
ARG MAJOR=1
ARG MINOR=0

# Compute changelist from Git if available, update LaTeX version, compile PDF, run Doxygen, create ZIP
RUN CHANGELIST=$(git rev-list --count HEAD 2>/dev/null || echo 0) && \
    VERSION="${MAJOR}.${MINOR}.${CHANGELIST}" && \
    echo "Building version: $VERSION" && \
    sed -i "s/VERSION_PLACEHOLDER/$VERSION/" docs/report.tex && \
    pdflatex docs/report.tex -output-directory=docs && \
    doxygen Doxyfile && \
    mkdir -p release && \
    zip -r release/my_devops_project_v$VERSION.zip src/ tests/ docs/report.pdf docs/doxygen/html Dockerfile requirements.txt

# Default command
CMD ["bash"]
