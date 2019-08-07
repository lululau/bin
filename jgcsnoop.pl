#!/usr/sbin/dtrace -s
/*
 *  jgcsnoop.d - JVM GC statistics
 *  (C) Copyright 2008 Georgios Gousios <gousiosg@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#pragma D option quiet

hotspot$1:::mem-pool-gc-begin
{
    self->str_ptr = (char*) copyin(arg0, arg1+1);
    self->str_ptr[arg1] = '\0';
    self->manager = (string) self->str_ptr;

    self->str_ptr = (char*) copyin(arg2, arg3+1);
    self->str_ptr[arg3] = '\0';
    self->mempool = (string) self->str_ptr;

    self->ts[self->manager, self->mempool] = timestamp;
}

hotspot$1:::mem-pool-gc-end
{
    self->str_ptr = (char*) copyin(arg0, arg1+1);
    self->str_ptr[arg1] = '\0';
    self->manager = (string) self->str_ptr;

    self->str_ptr = (char*) copyin(arg2, arg3+1);
    self->str_ptr[arg3] = '\0';
    self->mempool = (string) self->str_ptr;

    self->total = (timestamp - self->ts[self->manager, self->mempool]) / 1000000;
    self->ts[self->manager, self->mempool] = 0;	

    printf(
        "GC: %-20s(%s):%2d msec\n", self->mempool, self->manager, self->total);
    @pool_count[self->mempool] = count();
    @pool_time [self->mempool] = sum(self->total);
}

:::END
{
    printa(@pool_count);
    printa(@pool_time);
}

