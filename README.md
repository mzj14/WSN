# WSN
Code For WSN experiment in subject "Computer Network"

## Project structure

    Experiment 1 - Multi-hop Sensor Data Collection

### Sense Node
`Mote`

### Relay Node
`Relay`

### Base Station Node
`BaseStation`

### Generate Data File
`PC_File`

### Visualize Data
`PC_Visualization`


    Experiment 2 - Multi-hop Sensor Data Collection

### Random Data Sender
`RandomSender`

### Data Propagation
`DataAggregation` && `DataAggregation Helper`

### Acknowledgement Node
`Mock`

## Prerequisites
`TinyOS` `JDK` `Linux OS`

## Usage

### To install node applications
Run:
```
make telosb install,<node_id>
```

### To watch serial interface data transfer between PC and base station
Run:
```
java net.tinyos.sf.SerialForwarder
```

### To output sensor data to file
Run:
```
make

./run
```
in `PC_File`

### To visualize sensor data
Run:
```
make

./run
```
in `PC_Visual`
